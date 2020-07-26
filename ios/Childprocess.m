#import "Childprocess.h"
#import <React/RCTUtils.h>

@implementation Childprocess

int ID_INC = 0;

NSMutableDictionary *tasks;

- (id)init {
	if (self = [super init]) {
		tasks = [NSMutableDictionary dictionary];
	}
	return self;
}

+ (BOOL)requiresMainQueueSetup
{
	return YES;
}

RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(spawn,
		spawnWithCmd:
		(nonnull NSString*)cmd
	withArguments:(nonnull NSArray*)arguments
	withOptions:(nonnull NSDictionary*)options
	withResolver:(RCTPromiseResolveBlock)resolve
	withRejecter:(RCTPromiseRejectBlock)reject
) {
	NSNumber *cmdID = [self executeCommand:cmd arguments:arguments options:options];
	if (cmdID < (NSNumber *) 0) {
		reject(@"failed", @"execute command failed", RCTErrorWithMessage(@"execute command failed"));
	} else {
		resolve(cmdID);
	}
}

RCT_REMAP_METHOD(kill,
		killWithCmdID:
		(nonnull NSNumber*)cmdID
	withResolver:(RCTPromiseResolveBlock)resolve
	withRejecter:(RCTPromiseRejectBlock)reject
) {
	NSTask *task = tasks[cmdID];
	if (task == nil) {
		reject(@"invalid cmdID", @"invalid cmdID", RCTErrorWithMessage(@"invalid cmdID"));
	} else {
		if (task.running) {
			[task terminate];
		}
		[tasks removeObjectForKey:cmdID];
		resolve(cmdID);
	}
}

- (NSArray<NSString *> *)supportedEvents {
	return @[@"stdout", @"stderr", @"terminate"];
}

- (NSNumber *)executeCommand:(NSString *)cmd arguments:(NSArray *)arguments options:(NSDictionary *)options {
	NSNumber *cmdID = @(++ID_INC);

	NSTask *task = [[NSTask alloc] init];
	[task setExecutableURL:[NSURL fileURLWithPath:cmd]];
	[task setArguments:arguments];

	NSString *pwd = [options valueForKey:@"pwd"];
	if(pwd != nil){
		[task setCurrentDirectoryURL:[NSURL fileURLWithPath:pwd]];
	}

	NSPipe *stdoutPipe = [NSPipe pipe];
	NSPipe *stderrPipe = [NSPipe pipe];
	[task setStandardOutput:stdoutPipe];
	[task setStandardError:stderrPipe];
	NSFileHandle *stdoutHandle = [stdoutPipe fileHandleForReading];
	NSFileHandle *stderrHandle = [stderrPipe fileHandleForReading];

	stdoutHandle.readabilityHandler = ^void(NSFileHandle *handle) {
		NSString *type = @"stdout";

		NSData *data = [handle availableData];
		if(data.length > 0) {
			NSString *output = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"cmd[%@][%@]> %@", cmdID, type, output);
			[self sendEventWithName:type body:@{@"event": type, @"id": cmdID, @"output": output}];
		}
	};

	stderrHandle.readabilityHandler = ^void(NSFileHandle *handle) {
		NSString *type = @"stderr";

		NSData *data = [handle availableData];
		if(data.length > 0){
			NSString *output = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"cmd[%@][%@]> %@", cmdID, type, output);
			[self sendEventWithName:type body:@{@"event": type, @"id": cmdID, @"output": output}];
		}
	};

	task.terminationHandler = ^void(NSTask *task) {
		NSString *type = @"terminate";

		NSLog(@"cmd[%@][%@]", cmdID, @"terminate");
		[self sendEventWithName:@"terminate" body:@{@"event": type}];
	};

	tasks[cmdID] = task;

	NSError *error;
	[task launchAndReturnError:&error];

	return error == nil ? cmdID : @(-1);
}

@end
