/*
 *    AppSync for iOS
 *    https://github.com/linusyang/AppSync
 *
 *    Cydia Substrate tweak for arbitrary IPA package sync
 *    Work with iOS 5 through 8.1
 *    Copyright (c) 2014 Linus Yang <laokongzi (at) gmail.com>
 *
 *    AppSync is NOT for piracy. Use it legally.
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import <Foundation/Foundation.h>
#import <Security/Security.h>

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.10
#endif

#define SHOW_INFO 1

/* Minimal Cydia Substrate header */
typedef const void *MSImageRef;
MSImageRef MSGetImageByName(const char *file);
void *MSFindSymbol(MSImageRef image, const char *name);
void MSHookFunction(void *symbol, void *replace, void **result);

#ifdef DEBUG
#define LOG(...) NSLog(@"AppSync: " __VA_ARGS__)
#else
#define LOG(...)
#endif

#define DECL_FUNC(name, ret, ...) \
    static ret (*original_ ## name)(__VA_ARGS__); \
    ret custom_ ## name(__VA_ARGS__)
#define HOOK_FUNC(name, image) do { \
    void *_ ## name = MSFindSymbol(image, "_" #name); \
    if (_ ## name == NULL) { \
        LOG(@"Failed to load symbol: " #name "."); \
        return; \
    } \
    MSHookFunction(_ ## name, (void *) custom_ ## name, (void **) &original_ ## name); \
} while(0)
#define LOAD_IMAGE(image, path) do { \
    image = MSGetImageByName(path); \
    if (image == NULL) { \
        LOG(@"Failed to load " #image "."); \
        return; \
    } \
} while (0)

#define kSecMagicBytesLength 2
static const uint8_t kSecMagicBytes[kSecMagicBytesLength] = {0xa1, 0x13};
#define kSecSubjectCStr "Apple iPhone OS Application Signing"

#if SHOW_INFO
#define kInfoBytesLength 10
static const uint32_t kInfoBytes[kInfoBytesLength] = {0x68e8f97, 0xc67e14de, 0xf16768c, 0xc69e4636, 0x4eac0c4e, 0x14440c9e, 0x8c84ac0c, 0x6e467ea7, 0x940fc606, 0x7e350d0e};
#define ROR(x) (((x) >> 3) | ((x) << 29))
#endif

static void copyIdentifierAndEntitlements(NSString *path, NSString **identifier, NSDictionary **info)
{
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    NSString *bundleIdentifier = [bundle bundleIdentifier];
    if (bundleIdentifier != nil) {
        *identifier = [[NSString alloc] initWithString:bundleIdentifier];
    }
    NSString *executablePath = [bundle executablePath];
    NSData *content = [NSData dataWithContentsOfFile:executablePath];
    NSRange startRange = [content rangeOfData:[@"<plist" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, content.length)];
    NSRange endRange = [content rangeOfData:[@"</plist>" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, content.length)];
    if (startRange.location != NSNotFound &&
        endRange.location != NSNotFound &&
        endRange.location - startRange.location > 0) {
        NSString *contentString = [[NSString alloc] initWithData:[content subdataWithRange:NSMakeRange(startRange.location, endRange.location - startRange.location)] encoding:NSUTF8StringEncoding];
        NSError *error;
        NSString *xmlContent = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n%@</plist>", contentString];
        [contentString release];
        NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:[xmlContent dataUsingEncoding:NSUTF8StringEncoding] options:NSPropertyListImmutable format:NULL error:&error];
        if (plist != nil) {
            *info = [[NSDictionary alloc] initWithDictionary:plist];
        }
    }
}

DECL_FUNC(SecCertificateCreateWithData, SecCertificateRef, CFAllocatorRef allocator, CFDataRef data)
{
    SecCertificateRef result = original_SecCertificateCreateWithData(allocator, data);
    if (result == NULL) {
        CFDataRef dataRef = CFDataCreate(NULL, kSecMagicBytes, kSecMagicBytesLength);
        if (data != NULL && CFEqual(dataRef, data)) {
            result = (SecCertificateRef) dataRef;
        } else {
            CFRelease(dataRef);
        }
    }
    return result;
}

DECL_FUNC(SecCertificateCopySubjectSummary, CFStringRef, SecCertificateRef certificate)
{
    if (CFGetTypeID(certificate) == CFDataGetTypeID()) {
        return CFStringCreateWithCString(NULL, kSecSubjectCStr, kCFStringEncodingUTF8);
    }
    CFStringRef result = original_SecCertificateCopySubjectSummary(certificate);
    return result;
}

DECL_FUNC(MISValidateSignatureAndCopyInfo, uintptr_t, NSString *path, uintptr_t b, NSDictionary **info)
{
#if SHOW_INFO
    static uint8_t crBytes[(kInfoBytesLength << 2) + 1] = {0};
    static dispatch_once_t crOnceToken;
    dispatch_once(&crOnceToken, ^{
        uint8_t key = kSecMagicBytes[0];
        for (int i = 0; i < kInfoBytesLength; i++) {
            crBytes[(i << 2) + 1] = ((ROR(kInfoBytes[i]) >> 16) & 0xff) ^ key;
            crBytes[(i << 2) + 3] = (ROR(kInfoBytes[i]) & 0xff) ^ key;
            crBytes[i << 2] = ((ROR(kInfoBytes[i]) >> 24) & 0xff) ^ key;
            crBytes[(i << 2) + 2] = ((ROR(kInfoBytes[i]) >> 8) & 0xff) ^ key;
        }
    });
    NSString *crString = [NSString stringWithCString:(const char *) crBytes encoding:NSUTF8StringEncoding];
    NSLog(crString, nil);
#endif
    original_MISValidateSignatureAndCopyInfo(path, b, info);
    if (info == NULL) {
        LOG(@"Boo, NULL info");
    } else if (*info == nil) {
        LOG(@"Ahh, nil info, fake it");
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                MSImageRef imageSec;
                LOAD_IMAGE(imageSec, "/System/Library/Frameworks/Security.framework/Security");
                HOOK_FUNC(SecCertificateCreateWithData, imageSec);
                HOOK_FUNC(SecCertificateCopySubjectSummary, imageSec);
                LOG(@"Security.framework injected");
            });

            NSMutableDictionary *fakeInfo = [[NSMutableDictionary alloc] init];
            NSDictionary *entitlements = nil;
            NSString *identifier = nil;
            copyIdentifierAndEntitlements(path, &identifier, &entitlements);
            if (entitlements != nil) {
                [fakeInfo setObject:entitlements forKey:@"Entitlements"];
                [entitlements release];
            }
            if (identifier != nil) {
                [fakeInfo setObject:identifier forKey:@"SigningID"];
                [identifier release];
            }
            [fakeInfo setObject:[NSData dataWithBytes:kSecMagicBytes length:kSecMagicBytesLength] forKey:@"SignerCertificate"];
            [fakeInfo setObject:[NSDate date] forKey:@"SigningTime"];
            [fakeInfo setObject:[NSNumber numberWithBool:NO] forKey:@"ValidatedByProfile"];
            *info = fakeInfo;
        }
    } else {
        LOG(@"Hooray, info is okay");
    }
    LOG(@"info: %@", *info);
    return 0;
}

%ctor {
    @autoreleasepool {
        MSImageRef image;
        LOAD_IMAGE(image, "/usr/lib/libmis.dylib");
        HOOK_FUNC(MISValidateSignatureAndCopyInfo, image);
        LOG(@"libmis.dylib injected");
    }
}
