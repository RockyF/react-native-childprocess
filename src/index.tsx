import { NativeModules } from 'react-native';

type ChildprocessType = {
  spawn(cmd: string, params?: any[], options?: any, stdoutCallback?: (line:string)=>void): Promise<number>;
};

const { Childprocess } = NativeModules;

export default Childprocess as ChildprocessType;
