
#import "RNLaunchDarkly.h"
#import "DarklyConstants.h"

@implementation RNLaunchDarkly

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"FeatureFlagChanged"];
}

RCT_EXPORT_METHOD(cleanUserData) {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ldUserModelDictionary"];
}

RCT_EXPORT_METHOD(configure
                  :(NSString *)apiKey
                  options:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                 )
{
    NSLog(@"configure with %@", options);

    NSString* key           = options[@"key"];
    NSString* firstName     = options[@"firstName"];
    NSString* lastName      = options[@"lastName"];
    NSString* email         = options[@"email"];
    NSNumber* isAnonymous   = options[@"isAnonymous"];
    NSString* organization  = options[@"organization"];

    LDConfig *config = [[LDConfig alloc] initWithMobileKey:apiKey];

    LDUserBuilder *builder = [[LDUserBuilder alloc] init];
    builder.key = key;

    if (firstName) {
        builder.firstName = firstName;
    }

    if (lastName) {
        builder.lastName = lastName;
    }

    if (email) {
        builder.email = email;
    }

    if (organization) {
        builder.customDictionary[@"organization"] = organization;
    }

    if([isAnonymous isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        builder.isAnonymous = TRUE;
    }


    @try {
        if ( self.user ) {
            [[LDClient sharedInstance] updateUser:builder];
            resolve(@"true");
            return;
        } else {
          self.user = [builder build];

        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(handleFeatureFlagChange:)
         name:kLDFlagConfigChangedNotification
         object:nil];
        }
    }
    @catch (NSException * exception) {
        NSMutableDictionary * info = [NSMutableDictionary dictionary];
        [info setValue:exception.name forKey:@"ExceptionName"];
        [info setValue:exception.reason forKey:@"ExceptionReason"];
        [info setValue:exception.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
        [info setValue:exception.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
        [info setValue:exception.userInfo forKey:@"ExceptionUserInfo"];

        NSError *error = [[NSError alloc] initWithDomain:@"LaunchDakrly" code:500 userInfo:info];
        reject(@"Configure error", @"Couldnt configure Launch Darkly", error);
        return;
    }

    @try {
        [[LDClient sharedInstance] start:config withUserBuilder:builder];
        resolve(@"true");
    }
    @catch (NSException * exception) {
        NSMutableDictionary * info = [NSMutableDictionary dictionary];
        [info setValue:exception.name forKey:@"ExceptionName"];
        [info setValue:exception.reason forKey:@"ExceptionReason"];
        [info setValue:exception.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
        [info setValue:exception.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
        [info setValue:exception.userInfo forKey:@"ExceptionUserInfo"];

        NSError *error = [[NSError alloc] initWithDomain:@"LaunchDakrly" code:500 userInfo:info];
        reject(@"Configure error", @"Couldnt configure Launch Darkly", error);
    }
}

RCT_EXPORT_METHOD(boolVariation:(NSString*)flagName fallback:(BOOL)fallback callback:(RCTResponseSenderBlock)callback) {
    BOOL showFeature = [[LDClient sharedInstance] boolVariation:flagName fallback:fallback];
    callback(@[[NSNumber numberWithBool:showFeature]]);
}

RCT_EXPORT_METHOD(stringVariation:(NSString*)flagName fallback:(NSString*)fallback callback:(RCTResponseSenderBlock)callback) {
    NSString* flagValue = [[LDClient sharedInstance] stringVariation:flagName fallback:fallback];
    callback(@[flagValue]);
}

- (void)handleFeatureFlagChange:(NSNotification *)notification
{
    NSString *flagName = notification.userInfo[@"flagkey"];
    [self sendEventWithName:@"FeatureFlagChanged" body:@{@"flagName": flagName}];
}

RCT_EXPORT_MODULE()

@end
