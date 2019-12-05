import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';

import 'package:flutter_app_agree_annimation/agreerouter/RouteParser.dart';
import 'package:flutter_app_agree_annimation/agreerouter/RouterWriter.dart';
import 'package:source_gen/source_gen.dart';

import 'agrrerouter.dart';

//解析被AgreeRoute注解过的界面
class RouteParseGenerator extends GeneratorForAnnotation<AgreeRoute> {
  static RouteParser routeParser = RouteParser();

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    routeParser.parseRoute(element, annotation, buildStep);
    return null;
  }
}

///生成Router逻辑
class RouterGenerator extends GeneratorForAnnotation<AgreeRouter> {
  RouteParser routeParser() {
    return RouteParseGenerator.routeParser;
  }

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    return RouterWriter(routeParser()).write();
  }
}