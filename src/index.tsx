import {NativeModules, NativeEventEmitter} from 'react-native';

const Childprocess = NativeModules.Childprocess;
const childprocessEmitter = new NativeEventEmitter(Childprocess);

const subscriptions = {};

interface SpawnOptions {
	pwd?: string,
	stdout?: (output: string) => void,
	stderr?: (err: string) => void,
	terminate?: (code: number) => void,
}

export async function spawn(cmd: string, args?: string[], options?: SpawnOptions = {}): Promise<number> {
	const {pwd, stdout, stderr, terminate} = options;
	let opt = {
		pwd,
	};

	const cmdID = await Childprocess.spawn(cmd, args, opt);
	const stdoutSubscription = childprocessEmitter.addListener(
		'stdout',
		({output, id}) => {
			if (id === cmdID) {
				stdout && stdout(output);
			}
		}
	);
	const stderrSubscription = childprocessEmitter.addListener(
		'stderr',
		({output, id}) => {
			if (id === cmdID) {
				stderr && stderr(output);
			}
		}
	);
	const terminateSubscription = childprocessEmitter.addListener(
		'terminate',
		({code, id}) => {
			if (id === cmdID) {
				removeSubscriptions(cmdID);
				terminate && terminate(code);
			}
		}
	);
	subscriptions[cmdID] = {stdoutSubscription, stderrSubscription, terminateSubscription};

	return cmdID;
}

export async function kill(cmdID) {
	removeSubscriptions(cmdID);

	try {
		await Childprocess.kill(cmdID)
	} catch (e) {
		console.log(e);
	}
}

function removeSubscriptions(cmdID) {
	let ss = subscriptions[cmdID];
	if (ss) {
		const {stdoutSubscription, stderrSubscription, terminateSubscription} = ss;
		stdoutSubscription.remove();
		stderrSubscription.remove();
		terminateSubscription.remove();

		delete subscriptions[cmdID];
	}
}
