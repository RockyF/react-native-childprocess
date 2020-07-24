#import "Childprocess.h"

@implementation Childprocess

int ID_INC = 0;

RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(spawn,
								 spawnWithCmd:(nonnull NSString*)cmd
								 withArguments:(nonnull NSArray*)arguments
								 withOptions:(nonnull NSDictionary*)options
								 withResolver:(RCTPromiseResolveBlock)resolve
								 withRejecter:(RCTPromiseRejectBlock)reject
								 )
{
	NSNumber *cmdId = [self executeCommand:cmd arguments:arguments];
	resolve(cmdId);
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"stdout"];
}

- (NSNumber *)executeCommand: (NSString *)cmd arguments:(NSArray*)arguments {
	NSNumber *cmdId = @(ID_INC++);

	/*NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:cmd];
	[task setArguments:arguments];*/

	NSError *error;
	NSTask *task = [NSTask launchedTaskWithExecutableURL:[NSURL URLWithString:cmd] arguments:arguments error:&error terminationHandler:^(NSTask *task) {

	}];

	NSPipe *pipe = [NSPipe pipe];
	[task setStandardOutput:pipe];
	[task setStandardError:pipe];
	NSFileHandle *handle = [pipe fileHandleForReading];

	[self performSelectorInBackground:@selector(subProcessLoop:) withObject:@[handle, cmdId]];

	return cmdId;
}

-(void)subProcessLoop: (NSArray *)args{
	NSTask *task = args[0];
	NSNumber *cmdId = args[1];

	//[task launch];

	while(true){
		NSString *output = [[NSString alloc] initWithData:[handle availableData] encoding:NSASCIIStringEncoding];
		NSLog(@"cmd[%@]> %@", cmdId, output);
		[self sendEventWithName:@"stdout" body:@{@"id": cmdId, @"output": output}];
	}
}

@end
