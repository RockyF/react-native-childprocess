import { NativeModules } from 'react-native';

type ChildprocessType = {
  spawn(cmd: string, params?: any[], options?: any): Promise<number>;
};

const { Childprocess } = NativeModules;

export default Childprocess as ChildprocessType;
