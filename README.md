# react-native-childprocess

Childprocess implemented

## Installation

```sh
npm install react-native-childprocess
or
yarn add react-native-childprocess
```

## Usage

```js
import {spawn, kill} from 'react-native-childprocess'

let cmdID;

export async function start(){
	cmdID = await spawn('/sbin/ping', ['google.com'], {
		pwd: project.path,
		stdout: (output) => {
			console.log('>>>', output)
		}
	});
}

export async function stop(){
	kill(cmdID);
}
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
