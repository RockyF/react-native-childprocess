#import "Childprocess.h"

@implementation Childprocess

RCT_EXPORT_MODULE()

// Example method
// See // https://facebook.github.io/react-native/docs/native-modules-ios
RCT_REMAP_METHOD(spawn,
                 spawnWithCmd:(nonnull NSString*)cmd withParams:(nonnull NSArray*)params withOptions:(nonnull NSDictionary*)options
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
  //NSNumber *result = @([a floatValue] * [b floatValue]);

  resolve(0);
}

@end
