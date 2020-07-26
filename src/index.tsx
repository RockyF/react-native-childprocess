import {NativeModules, NativeEventEmitter} from 'react-native';

interface SpawnOptions {
	pwd?: string,
	stdout?: (output: string) => void,
	stderr?: (err: string) => void,
	terminate?: (code: number) => void,
}

const Childprocess = NativeModules.Childprocess;
const childprocessEmitter = new NativeEventEmitter(Childprocess);

const subscriptions = {};

function onEvent({output, id, event}){
	let subscription = subscriptions[id];
	subscription && subscription[event] && subscription[event](output);
}

childprocessEmitter.addListener(
	'stdout',
	onEvent,
);
childprocessEmitter.addListener(
	'stderr',
	onEvent,
);
childprocessEmitter.addListener(
	'terminate',
	onEvent,
);

export async function spawn(cmd: string, args?: string[], options?: SpawnOptions = {}) {
	const {pwd, stdout, stderr, terminate} = options;
	let opt = {
		pwd,
	};

	const cmdID = await Childprocess.spawn(cmd, args, opt);
	subscriptions[cmdID] = {
		stdout,
		stderr,
		terminate: function(payload){
			removeSubscriptions(cmdID);
			terminate && terminate(payload);
		},
	};

	return cmdID;
}

function removeSubscriptions(cmdID) {
	let ss = subscriptions[cmdID];
	if (ss) {
		delete subscriptions[cmdID];
	}
}

export async function kill(cmdID:number) {
	removeSubscriptions(cmdID);

	try {
		await Childprocess.kill(cmdID)
	} catch (e) {
		console.log(e);
	}
}
