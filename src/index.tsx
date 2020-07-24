import {NativeModules} from 'react-native';

const Childprocess = NativeModules.Childprocess;

Childprocess.addListener(
	'stdout',
	() => {
		console.log(arguments);
	}
);

export async function spawn(cmd: string, args?: string[], options?: any, stdout?: (output: string) => void, stderr?: (err: string) => void) {
	const cmdId = await Childprocess.spawn(cmd, args, options);
	/*Childprocess.addListener(
		'stdout',
		({output, id}) => {
			if(id === cmdId){
				stdout && stdout(output);
			}
		}
	);*/
}
