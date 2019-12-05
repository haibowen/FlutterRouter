import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

import 'package:flutter_app_agree_annimation/agreerouter/agrrerouter.dart';

//解析注解后需要提取的信息

class RouteParser{
  //注解的url参数，跟类名的映射map
  Map<String,dynamic> routeMap={};
  //被注解的类的实际路径的存储list
  List<String> importList=[];
  void parseRoute(ClassElement element,ConstantReader annotation,BuildStep  buildStep){
    print('start parseRoute for ${element.displayName}');
    //获取注解里的参数, annotation 有两个方法，read()跟peek()，peek()方法更加安全
    String url=annotation.peek("url").stringValue;
    try{
      Uri uri=Uri.parse(url);
      //对注解里的url进行scheme判断，看是否是我们自定义的url
      if(uri.scheme!='agree'){
        print('parsing failed:error scheme for $url');
        return;
      }
      //对注解里的url进行host 判断，看是否符合我们自定义的url格式
      if(uri.host!='flutter'){
        print("parsing failed:error host for $url");
        return;
      }
      //对注解里的url进行路径判断，看是否符合我们自定义的url的格式
      if(uri.path==null){
        print('parsing failed:error path for$url');
        return;
      }
      //routeMap里初始化判空
      String pathKey="'"+uri.path+"'";
//      if(routeMap[pathKey]!=null){
//        print('parse route error:alerdy exit for $url');
//        return;
//      }
      //给routeMap 赋值
      routeMap[pathKey]=element.displayName;
      //存储下每个被注解的页面的路径
      if(buildStep.inputId.path.contains('lib/')){
        print(buildStep.inputId.path);
        importList.add(
          "package:${buildStep.inputId.package}/${buildStep.inputId.path.replaceFirst('lib/', '')}"
        );
      }else{
        importList.add("${buildStep.inputId.path}");
      }
    }catch(e){
      print('parse route error $e');
    }
  }

}