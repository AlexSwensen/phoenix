/*
 * Phoenix is released under the MIT License. Refer to https://github.com/kasper/phoenix/blob/master/LICENSE.md
 */

#import "PHAppDelegate.h"
#import "PHContext.h"
#import "PHEventConstants.h"
#import "PHOpenAtLoginHelper.h"
#import "PHPreferences.h"
#import "PHUniversalAccessHelper.h"

@interface PHAppDelegate ()

@property PHContext *context;
@property NSStatusItem *statusItem;

#pragma mark - IBOutlet

@property (weak) IBOutlet NSMenu *statusItemMenu;

@end

@implementation PHAppDelegate

#pragma mark - Initialising

- (void) toggleStatusItem:(BOOL)enabled {

    // Remove status item
    if (!enabled) {
        [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
        self.statusItem = nil;
        return;
    }

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.image = [NSImage imageNamed:@"StatusItemIcon"];
    self.statusItem.menu = self.statusItemMenu;
}

#pragma mark - NSApplicationDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)__unused notification {

    [PHUniversalAccessHelper askPermissionIfNeeded];

    self.context = [PHContext context];
    [self.context load];

    [self toggleStatusItem:![[PHPreferences sharedPreferences] isDaemon]];

    // Observe changes in preferences
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferencesDidChange:)
                                                 name:PHPreferencesDidChangeNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:PHEventStartNotification object:self];
}

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)application {

    [[NSNotificationCenter defaultCenter] postNotificationName:PHEventWillTerminateNotification object:nil];

    [self.context shouldTerminate:^{

        [application replyToApplicationShouldTerminate:YES];
    }];

    return NSTerminateLater;
}

#pragma mark - NSMenuDelegate

- (void) menuNeedsUpdate:(NSMenu *)menu {

    [menu itemWithTitle:@"Open at Login"].state = [PHOpenAtLoginHelper opensAtLogin] ? NSOnState : NSOffState;
}

#pragma mark - Notification Handling

- (void) preferencesDidChange:(NSNotification *)__unused notification {

    [self toggleStatusItem:![[PHPreferences sharedPreferences] isDaemon]];
    [PHOpenAtLoginHelper setOpensAtLogin:[[PHPreferences sharedPreferences] openAtLogin]];
}

#pragma mark - IBAction

- (IBAction) reloadContext:(id)__unused sender {

    [self.context load];
}

- (IBAction) showAboutPanel:(id)sender {

    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:sender];
}

- (IBAction) toggleOpenAtLogin:(NSMenuItem *)sender {

    [PHOpenAtLoginHelper setOpensAtLogin:sender.state == NSOffState];
}

@end
