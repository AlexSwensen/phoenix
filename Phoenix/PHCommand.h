/*
 * Phoenix is released under the MIT License. Refer to https://github.com/kasper/phoenix/blob/master/LICENSE.md
 */

@import Foundation;
@import JavaScriptCore;

@protocol PHCommandJSExport <JSExport>

#pragma mark - Actions

JSExportAs(run, + (BOOL) runPath:(NSString *)path withArguments:(NSArray<NSString *> *)arguments);

@end

@interface PHCommand : NSObject <PHCommandJSExport>

@end
