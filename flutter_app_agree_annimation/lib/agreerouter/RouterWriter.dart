
import 'package:flutter_app_agree_annimation/agreerouter/RouteParser.dart';
import 'package:flutter_app_agree_annimation/agreerouter/tpl.dart';

import 'package:mustache4dart/mustache4dart.dart';

//写入生成一个文件
class RouterWriter {
  final RouteParser routeParser;
  RouterWriter(this.routeParser);
  //
  String creatInstance() {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('switch(clazz){');
    routeParser.routeMap.forEach((String path, dynamic type) {
      buffer.writeln('case $type:return $type(option);');
    });
    buffer..writeln('default:return null;')..writeln('}');
    return buffer.toString();
  }

  //
  List<Map<String, String>> createImports() {
    final List<Map<String, String>> imports = <Map<String, String>>[];
    final Function addRef = (String path) {
      imports.add(<String, String>{'path': path});
    };
    routeParser.importList.forEach(addRef);
    return imports;
  }

  //
  String write() {
    return render(routerTpl,<String,dynamic>{
      'imports' :createImports(),
      'classInstance' :creatInstance(),
      'routeMap':routeParser.routeMap.toString()
    });

  }
}
