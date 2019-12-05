
import 'package:flutter_app_agree_annimation/agreerouter/agrrerouter.dart';

import 'MyArouter.internal.dart';



@AgreeRouter()
class MyArouter{
  AgreeRouterInternal internalImpl = AgreeRouterInternalImpl();
  dynamic getPage(String url) {
    AgreeRouteResult result = internalImpl.routerInternal(url);
    if(result.agreeRouteResultState == AgreeRouteResultState.NOT_FOUND) {
      print("Router error: page not found");
      return null;
    }
    return result.widget;
  }

}