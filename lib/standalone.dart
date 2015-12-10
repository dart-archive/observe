library observe.standalone;

import 'package:observe/src/metadata.dart';
export "package:observe/observe.dart";
@GlobalQuantifyCapability("observe.src.change_notifier.ChangeNotifier",observableObjectBridge)
import "package:reflectable/reflectable.dart";


class ObservableObjectBridge extends Reflectable {
  const ObservableObjectBridge() : super.fromList(const [
    const InstanceInvokeMetaCapability(ObservableProperty),
    subtypeQuantifyCapability,typeCapability,declarationsCapability
  ]);
}


const observableObjectBridge = const ObservableObjectBridge();


Map<String, Iterable<Reflectable>> scopeMap = <String, Iterable<Reflectable>>{
  "observe": <Reflectable>[observableObjectBridge]
};

@ScopeMetaReflector()
Iterable<Reflectable> reflectablesOfScope(String scope) => scopeMap[scope];
