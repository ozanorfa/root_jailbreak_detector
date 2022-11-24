#import "RootJailbreakDetectorPlugin.h"
#if __has_include(<root_jailbreak_detector/root_jailbreak_detector-Swift.h>)
#import <root_jailbreak_detector/root_jailbreak_detector-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "root_jailbreak_detector-Swift.h"
#endif

@implementation RootJailbreakDetectorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRootJailbreakDetectorPlugin registerWithRegistrar:registrar];
}
@end
