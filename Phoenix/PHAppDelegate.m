/*
 * Phoenix is released under the MIT License. Refer to https://github.com/kasper/phoenix/blob/master/LICENSE.md
 */

#import "PHAppDelegate.h"
#import "PHContext.h"
#import "PHKeyHandler.h"
#import "PHOpenAtLogin.h"
#import "PHUniversalAccessHelper.h"

@interface PHAppDelegate ()

@property PHContext *context;
@property NSStatusItem *statusItem;
@property id globalKeyDownMonitor;

#pragma mark IBOutlet

@property (weak) IBOutlet NSMenu *statusItemMenu;

@end

@implementation PHAppDelegate

#pragma mark - Initialise

- (void) setupStatusItem {

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.image = [NSImage imageNamed:@"StatusItemIcon"];
    self.statusItem.menu = self.statusItemMenu;
}

- (void) setupGlobalKeyDownMonitor {

    self.globalKeyDownMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event) {

        [self.context keyDown:event];
    }];
}

#pragma mark - NSApplicationDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)__unused notification {

    [PHUniversalAccessHelper askPermissionIfNeeded];
    
    self.context = [[PHContext alloc] init];
    [self.context load];

    [self setupStatusItem];
    [self setupGlobalKeyDownMonitor];
}

- (void) applicationWillTerminate:(NSNotification *)__unused notification {

    [NSEvent removeMonitor:self.globalKeyDownMonitor];
}

#pragma mark - NSMenuDelegate

- (void) menuNeedsUpdate:(NSMenu *)menu {

    [menu itemWithTitle:@"Open at Login"].state = [PHOpenAtLogin opensAtLogin] ? NSOnState : NSOffState;
}

#pragma mark - Delegate

- (void) reloadContext {

    [self.context load];
}

- (PHKeyHandler *) bindKey:(NSString *)key modifiers:(NSArray *)modifiers callback:(JSValue *)callback {

    return [self.context bindKey:key modifiers:modifiers callback:callback];
}

#pragma mark - IBAction

- (IBAction) reloadContext:(id)__unused sender {

    [self reloadContext];
}

- (IBAction) showAboutPanel:(id)sender {

    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:sender];
}

- (IBAction) toggleOpenAtLogin:(NSMenuItem *)sender {

    [PHOpenAtLogin setOpensAtLogin:sender.state == NSOffState];
}

@end
