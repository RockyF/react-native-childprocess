#import "Childprocess.h"

@implementation Childprocess

RCT_EXPORT_MODULE()

// Example method
// See // https://facebook.github.io/react-native/docs/native-modules-ios
RCT_REMAP_METHOD(spawn,
									spawnWithCmd:(nonnull NSString*)cmd withParams:(nullable NSArray*)params withOptions:(nullable NSDictionary*)options withStdoutCallback:(RCTResponseSenderBlock)stdoutCallback
								 withResolver:(RCTPromiseResolveBlock)resolve
								 withRejecter:(RCTPromiseRejectBlock)reject)
{
	//NSNumber *result = @([a floatValue] * [b floatValue]);
	[self performSelectorInBackground:@selector(executeCommand:) withObject:@"ping baidu.com"];

	resolve(0);
}

- (NSString *)executeCommand: (NSString *)cmd {
	NSString *output = [NSString string];
	FILE *pipe = popen([cmd cStringUsingEncoding: NSASCIIStringEncoding], "r+");
	if (!pipe) {
		return @"";
	}
	char buf[102400];
	while(fgets(buf, sizeof(buf), pipe) != NULL) {
		//        if('\n' == buf[strlen(buf)-1]) {
		//            buf[strlen(buf)-1] = '\0';
		//        }
		NSString *bufStr = [[NSString alloc] initWithUTF8String:buf];
		NSLog(@"%@", bufStr);
		stdoutCallback(@[[NSNull null], bufStr]);
		output = [output stringByAppendingFormat: @"%s ", buf];
	}

	pclose(pipe);
	return output;

}

@end
