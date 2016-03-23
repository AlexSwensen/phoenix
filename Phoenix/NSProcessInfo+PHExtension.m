/*
 * Phoenix is released under the MIT License. Refer to https://github.com/kasper/phoenix/blob/master/LICENSE.md
 */

#import "NSProcessInfo+PHExtension.h"

@implementation NSProcessInfo (PHExtension)

#pragma mark - Operating System

+ (BOOL) isOperatingSystemAtLeastElCapitan {

    NSOperatingSystemVersion elCapitan = { .majorVersion = 10, .minorVersion = 11, .patchVersion = 0 };
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:elCapitan];
}

@end
