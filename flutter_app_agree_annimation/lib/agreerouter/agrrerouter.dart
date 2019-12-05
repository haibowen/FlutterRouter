
//定义页面路由注解
class AgreeRoute {
  final String url;
  final String desc;
  const AgreeRoute({this.url, this.desc});
}

//定义路由解析注解器
class AgreeRouter{
  const AgreeRouter();
}

//路由参数选项
class AgreeRouteOption{
  String url;
  Map<String,dynamic> parames;
  AgreeRouteOption({this.url,this.parames});
}


//路由映射状态 NOT_FOUND 未找到 FOUND找到
enum AgreeRouteResultState{
  FOUND,
  NOT_FOUND
}

//路由结果
class AgreeRouteResult{
  dynamic widget;
  AgreeRouteResultState agreeRouteResultState;
  AgreeRouteResult({this.widget,this.agreeRouteResultState});

}

//路由内部接口
abstract class AgreeRouterInternal{
  AgreeRouteResult routerInternal(String url);

}
const Object agreeRouter=const AgreeRouter();
