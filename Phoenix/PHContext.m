/*
 * Phoenix is released under the MIT License. Refer to https://github.com/kasper/phoenix/blob/master/LICENSE.md
 */

#import "PHApp.h"
#import "PHCommand.h"
#import "PHContext.h"
#import "PHKeyHandler.h"
#import "PHModalWindowController.h"
#import "PHMouse.h"
#import "PHNotification.h"
#import "PHPathWatcher.h"
#import "PHPhoenix.h"
#import "PHWindow.h"

@interface PHContext ()

@property JSContext *context;
@property NSMutableSet *paths;
@property PHPathWatcher *watcher;
@property NSMutableDictionary *keyHandlers;
@property NSMutableDictionary *keyHandlersByIdentifier;

@end

@implementation PHContext

#if DEBUG
    static NSString * const PHConfigurationPath = @"~/.phoenix-debug.js";
#else
    static NSString * const PHConfigurationPath = @"~/.phoenix.js";
#endif

#pragma mark - Initialise

- (instancetype) init {

    if (self = [super init]) {
        self.paths = [NSMutableSet set];
        self.keyHandlers = [NSMutableDictionary dictionary];
        self.keyHandlersByIdentifier = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void) createConfigurationFile:(NSString *)path {

    BOOL fileCreated = [[NSFileManager defaultManager] createFileAtPath:path
                                                               contents:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                             attributes:nil];

    if (!fileCreated) {
        NSLog(@"Error: Could not create configuration file to path %@.", path);
        return;
    }

    [PHNotification deliver:[NSString stringWithFormat:@"Configuration file %@ was created.", path]];
}

#pragma mark - Resetting

- (void) resetConfigurationPaths {

    [self.paths removeAllObjects];
}

- (void) resetConfigurationWatcher {

    PHContext * __weak weakSelf = self;

    self.watcher = [PHPathWatcher watcherFor:[self.paths allObjects] handler:^{

        [[weakSelf class] cancelPreviousPerformRequestsWithTarget:weakSelf
                                                         selector:@selector(load)
                                                           object:nil];

        [weakSelf performSelector:@selector(load) withObject:nil afterDelay:0.5];
    }];
}

- (void) resetKeyHandlers {

    [self.keyHandlers.allValues makeObjectsPerformSelector:@selector(disable)];
    [self.keyHandlers removeAllObjects];
    [self.keyHandlersByIdentifier removeAllObjects];
}

#pragma mark - Setup

- (void) handleException:(id)exception {

    NSLog(@"%@", exception);
    [PHNotification deliver:[NSString stringWithFormat:@"%@", exception]];
}

- (NSString *) resolvePath:(NSString *)path {

    path = path.stringByStandardizingPath;

    // Resolve path
    if(![path isAbsolutePath]) {
        NSURL *relativeUrl = [NSURL URLWithString:PHConfigurationPath.stringByStandardizingPath];
        path = [NSURL URLWithString:path relativeToURL:relativeUrl].absoluteString;
    }

    return path.stringByStandardizingPath;
}

- (void) loadScript:(NSString *)path {

    NSError *error;
    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        NSLog(@"Error: Could not read file in path %@ to string. (%@)", path, error);
    }

    [self.context evaluateScript:script];
    [self.paths addObject:path];
}

- (void) setupAPI {

    PHContext * __weak weakSelf = self;

    self.context[@"Phoenix"] = [PHPhoenix class];
    self.context[@"Modal"] = [PHModalWindowController class];
    self.context[@"Command"] = [PHCommand class];
    self.context[@"Screen"] = [NSScreen class];
    self.context[@"Mouse"] = [PHMouse class];
    self.context[@"App"] = [PHApp class];
    self.context[@"Window"] = [PHWindow class];

    self.context[@"require"] = ^(NSString *path) {

        path = [weakSelf resolvePath:path];

        if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSString *message = [NSString stringWithFormat:@"Require: File %@ does not exist.", path];
            [weakSelf handleException:message];
            return;
        }

        [weakSelf loadScript:path];
    };
}

- (void) setupContext {

    PHContext * __weak weakSelf = self;

    // Create context
    self.context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    self.context.exceptionHandler = ^(__unused JSContext *context, JSValue *value) {

        [weakSelf handleException:value];
    };

    // Load context
    [self setupAPI];
    [self loadScript:[[NSBundle mainBundle] pathForResource:@"underscore-min" ofType:@"js"]];
    [self loadScript:[self resolvePath:PHConfigurationPath]];
}

#pragma mark - Loading

- (void) load {

    [self resetConfigurationPaths];
    [self resetKeyHandlers];
    
    NSString *configurationPath = [self resolvePath:PHConfigurationPath];

    // No configuration file found, create one for the user
    if (![[NSFileManager defaultManager] fileExistsAtPath:configurationPath]) {
        [self createConfigurationFile:configurationPath];
    }

    [self setupContext];
    [self resetConfigurationWatcher];

    NSLog(@"Context loaded.");
}

#pragma mark - Binding

- (PHKeyHandler *) bindKey:(NSString *)key modifiers:(NSArray *)modifiers callback:(JSValue *)callback {

    PHKeyHandlerBlock handler = ^{ [callback callWithArguments:@[]]; };
    PHKeyHandler *existingKeyHandler = self.keyHandlers[@([PHKeyHandler hashForKey:key modifiers:modifiers])];

    // Change handler for existing key
    if (existingKeyHandler) {
        existingKeyHandler.handler = handler;
        return existingKeyHandler;
    }

    // Bind new key
    PHKeyHandler *keyHandler = [PHKeyHandler withKey:key modifiers:modifiers handler:handler];
    self.keyHandlers[@(keyHandler.hash)] = keyHandler;
    self.keyHandlersByIdentifier[@(keyHandler.identifier)] = keyHandler;

    return keyHandler;
}

#pragma mark - Events

- (void) keyDown:(UInt32)identifier {

    PHKeyHandler *keyHandler = self.keyHandlersByIdentifier[@(identifier)];
    [keyHandler invoke];
}

@end
