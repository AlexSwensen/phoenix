/*
 * Phoenix is released under the MIT License. Refer to https://github.com/kasper/phoenix/blob/master/LICENSE.md
 */

@import Foundation;

@interface PHPathWatcher : NSObject

#pragma mark - Initialise

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithPaths:(NSArray<NSString *> *)paths handler:(void (^)())handler NS_DESIGNATED_INITIALIZER;

+ (PHPathWatcher *) watcherFor:(NSArray<NSString *> *)paths handler:(void (^)())handler;

@end
