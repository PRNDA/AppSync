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

#include <CoreFoundation/CoreFoundation.h>
#include <spawn.h>

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.10
#endif

#define PLIST_PATH_IOS_8 "/Library/LaunchDaemons/com.apple.mobile.installd.plist"
#define PLIST_PATH "/System" PLIST_PATH_IOS_8
#define LOG(s) fprintf(stdout, s "\n")

#ifdef BUILD_POSTINST
#define BUF_SIZE 256
#define DEFAULT_WAIT 2
#define CLOG(name) show_log(k ## name ## Bytes, k ## name ## Length)
#define ROR(x) (((x) >> 3) | ((x) << 29))

#define kLogKey (0x13)
#define kCopyrightLength 23
#define kInjectLength 35

static const uint32_t kCopyrightBytes[kCopyrightLength] = {0x931b1a02, 0x53eb819b, 0xabe3099b, 0xd2e2019b, 0x319b3bd9, 0xbe333a3, 0xd99959eb, 0x10ca83e1, 0x1b530bd3, 0xa3db399b, 0xdb81d199, 0x9191139, 0x9afbd3e9, 0x33019a53, 0x93eba0cb, 0xc9c99a31, 0x2b19ad2, 0x399afab2, 0xa292fafa, 0x51f99aea, 0xe19a1ad2, 0xa928252, 0x99c9c8c9};
static const uint32_t kInjectBytes[kInjectLength] = {0xe3330309, 0xe38bd3e9, 0xe38353e9, 0xcbb3833b, 0x99b9dbf9, 0x9333eb83, 0xdb833bfb, 0x9bfbd301, 0x399b83e3, 0xf1eb931b, 0x1bfbb1eb, 0xf3e38bd3, 0xfbb1ebd3, 0xeb033b93, 0xfbfbb99b, 0x799ba30b, 0xb3199a1b, 0xd2b99b7a, 0x9ba30bb1, 0x1999f3e3, 0x99a24119, 0xf15271c9, 0xa1d199e1, 0xfbd38b0a, 0x930b51e3, 0xf3e38bd2, 0xfbb20333, 0x8b033b0b, 0x933bb1e3, 0xf3e38bd2, 0xfbb20333, 0x8b033b0b, 0x933bb1eb, 0xbb53fbd3, 0x8898989b};

static void decrypt(const uint32_t *input, int length, uint8_t *output)
{
    int i = 0;
    for (i = 0; i < length; i++) {
        output[(i << 2) + 1] = ((ROR(input[i]) >> 16) & 0xff) ^ kLogKey;
        output[(i << 2) + 3] = (ROR(input[i]) & 0xff) ^ kLogKey;
        output[i << 2] = ((ROR(input[i]) >> 24) & 0xff) ^ kLogKey;
        output[(i << 2) + 2] = ((ROR(input[i]) >> 8) & 0xff) ^ kLogKey;
    }
    output[i << 2] = '\0';
}

static void show_log(const uint32_t *msg, int length)
{
    static uint8_t buf[BUF_SIZE] = {0};
    decrypt(msg, length, (uint8_t *) buf);
    fprintf(stdout, (const char *) buf, NULL);
}

static int inject_dylib(int wait_time)
{
    static uint8_t buf[BUF_SIZE] = {0};
    decrypt(kInjectBytes, kInjectLength, (uint8_t *) buf);
#ifdef DEBUG
    fprintf(stderr, "%s\n", buf);
    return 0;
#endif
    sleep(wait_time);
    return system((const char *) buf);
}
#endif

static int run_launchctl(const char *path, const char *cmd)
{
#ifdef DEBUG
    fprintf(stderr, "launchctl %s %s\n", cmd, path);
    return 0;
#endif
    const char *args[] = {"/bin/launchctl", cmd, path, NULL};
    pid_t pid;
    int stat;
    posix_spawn(&pid, args[0], NULL, NULL, (char **) args, NULL);
    waitpid(pid, &stat, 0);
    return stat;
}

int main(int argc, const char **argv)
{
#ifdef BUILD_POSTINST
    CLOG(Copyright);
#endif
#ifdef DEBUG
    if (argc > 1)
#else
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0)
#endif
    {
        run_launchctl(PLIST_PATH_IOS_8, "unload");
        run_launchctl(PLIST_PATH_IOS_8, "load");
#ifdef BUILD_POSTINST
        LOG("Manually injecting for iOS 8...");
        int wait_time = DEFAULT_WAIT;
        if (argc > 1) {
            wait_time = atoi(argv[1]);
            if (wait_time < DEFAULT_WAIT) {
                wait_time = DEFAULT_WAIT;
            }
        }
        if (inject_dylib(wait_time)) {
            LOG("Inject failed, try to reinstall");
        }
#else
        run_launchctl("/Library/LaunchDaemons/com.linusyang.appsync.plist", "unload");
#endif
    } else {
        run_launchctl(PLIST_PATH, "unload");
        run_launchctl(PLIST_PATH, "load");
#ifdef BUILD_POSTINST
        unlink("/Library/LaunchDaemons/com.linusyang.appsync.plist");
        unlink("/usr/bin/appsync");
#endif
    }
    return 0;
}
