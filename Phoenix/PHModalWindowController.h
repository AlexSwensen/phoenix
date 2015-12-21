/*
 * Phoenix is released under the MIT License. Refer to https://github.com/kasper/phoenix/blob/master/LICENSE.md
 */

@import Cocoa;
@import JavaScriptCore;

#import "PHIdentifiableJSExport.h"

@protocol PHModalWindowControllerJSExport <JSExport, PHIdentifiableJSExport>

#pragma mark Exported Properties

@property NSPoint origin;
@property NSTimeInterval duration;
@property (copy) NSString *message;

#pragma mark - Initialise

- (instancetype) init;

#pragma mark - Displaying

- (NSRect) frame;
- (void) show;

#pragma mark - Closing

- (void) close;

@end

@interface PHModalWindowController : NSWindowController <PHModalWindowControllerJSExport>

+ (instancetype) new NS_UNAVAILABLE;

#pragma mark Properties

@property NSPoint origin;
@property NSTimeInterval duration;
@property (copy) NSString *message;

@end
