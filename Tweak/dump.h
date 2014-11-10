/*
 *    dump.h
 *    AppSync for iOS
 *
 *    Copyright (c) 2014 Linus Yang
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
 */

#ifdef __cplusplus
extern "C" {
#endif

#include <CoreFoundation/CoreFoundation.h>

int copyEntitlementDataFromFile(const char *path, CFMutableDataRef output);

enum {
    kCopyEntSuccess = 0,
    kCopyEntArgumentNull = 1,
    kCopyEntMapFail = 2,
    kCopyEntMachO = 3,
    kCopyEntUnknown = 4
};

#ifdef DEBUG
enum {
    kCFLogLevelError = 3,
    kCFLogLevelWarning = 4
};
extern void CFLog(int32_t level, CFStringRef format, ...);
CFStringRef entErrorString(int code);
#endif

#ifdef __cplusplus
}
#endif
