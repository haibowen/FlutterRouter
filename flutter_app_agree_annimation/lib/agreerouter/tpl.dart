const String routerTpl="""
import 'package:flutter_app_agree_annimation/agreerouter/agrrerouter.dart';
{{#imports}}
import '{{{path}}}';
{{/imports}}
class AgreeRouterInternalImpl extends AgreeRouterInternal {
  AgreeRouterInternalImpl();
  final Map<String, dynamic> routeMap = {{{routeMap}}};
  @override
  AgreeRouteResult routerInternal(String url) {
    try {
      AgreeRouteOption option = AgreeRouteOption();
      final uri = Uri.parse(url);
      if(uri.scheme != 'easy') {
        return AgreeRouteResult(agreeRouteResultState: AgreeRouteResultState.NOT_FOUND);
      }
      if(uri.host != 'flutter') {
        return AgreeRouteResult(agreeRouteResultState: AgreeRouteResultState.NOT_FOUND);
      }
      String path =uri.path;
      if(path == null) {
        return AgreeRouteResult(agreeRouteResultState: AgreeRouteResultState.NOT_FOUND);
      }
      option.url = url;
      option.parames = uri.queryParameters;
      final Type pageClass = routeMap[path];
      if(pageClass == null) {
        return AgreeRouteResult(agreeRouteResultState: AgreeRouteResultState.NOT_FOUND);
      }
      final dynamic classInstance = createInstance(pageClass, option);
      return AgreeRouteResult(widget: classInstance, agreeRouteResultState: AgreeRouteResultState.FOUND);
    }
    catch(e) {
      return AgreeRouteResult(agreeRouteResultState: AgreeRouteResultState.NOT_FOUND);
    }
  }
  dynamic createInstance(Type clazz, AgreeRouteOption option) {
    {{{classInstance}}}
  }
}

""";