# AgreeRouter
一个基于Dart注解的Flutter路由管理框架
## <u>Flutter使用注解以及如何生成文件</u>

## <u>开篇</u>

在开始这篇文章之前我们先得明白，Flutter这边是不支持反射的，可能是Google为了性能所做的取舍吧！但是随着我们项目的开发越来越庞大，手动维护一个路由 元素的文件，一般是不太现实的，因此我们需要一个类似工厂的方法，来自动创建我们的页面实例，鉴于此我们必须来了解下注解----Dart的注解。

## <u>注解</u>

注解是代码级的配置，作用于编译时或者是运行时，由于Flutter目前不支持运行时的反射功能，因此我们必须在编译期间就能获取到注解的相关信息。我们要根据这些注解信息生成一个映射表，然后将此映射表编译到我们的工程里，供我们的工程调用，（这里的映射表通常是生成一个dart文件，以便在我们flutter里使用）

注解的工作过程基本是这样的，先对我们文件进行扫描---->对文件中的语法进行分析-------->提取注解------>筛选我们自己的注解----->将这些注解收集----->生成映射表。

## <u>source_gen</u>

dart提供了 build、analyser 、source_gen 这三个库，其中source_gen是利用了其他两个库，给到了一层比较好的注解拦截的封装。

build库：整套资源文件的处理

analyser库：对dart文件生成完备的语法结构

source_gen库:提供注解元素的拦截

这里source_gen是Dart中比较复杂的库，具体的有兴趣的可以自己查看source_gen的源码，这里附上他的主页： https://github.com/dart-lang/source_gen 

## <u>思考点</u>

在进行注解文件生成前我们要注意下面几个问题，

<u>问题</u>

（1）整个工程我们只需要生成一个配置映射文件，因此我们需要在所有文件扫描完毕以后在进行文件生成。这个怎么处理？

（2）source_gen 对一个类只支持一个注解，但是我们可能会存在多个URL指向一个页面的情况，这个又需要怎么处理？

<u>解决点</u>

（1）、我们需要将我们的注解分成两类，一类是去注解我们的页面即@AgreeRoute（）另一个用于注解使用者自己的router，即@AgreeRouter（）routerBuilder 拥有RouterGenerator实例，负责@AgreeRoute()的解析routeParseBuilder拥有RouteParseGenerator实例，负责@AgreeRouter()的解析

然后我们在项目的根目录下新建一个build.yaml文件来控制我们的生成顺序，最终只生成一个映射文件。

build.yaml配置文件如下：

```dart
targets:
  $default:
    builders:
      flutter_app_agree_annimation|route_parse_builder:
        enabled: true
        generate_for:
          exclude: ['**.internal.dart']
      flutter_app_agree_annimation|router_builder:
        enabled: true
        generate_for:
          exclude: ['**.internal.dart']

builders:
  router_builder:
    import: 'package:flutter_app_agree_annimation/agreerouter/builder.dart'
    builder_factories: ['routerBuilder']
    build_extensions: { '.router.dart': ['.internal.dart'] }
    auto_apply: root_package
    build_to: source

  route_parse_builder:
    import: 'package:flutter_app_agree_annimation/agreerouter/builder.dart'
    builder_factories: ['routeParseBuilder']
    build_extensions: { '.dart': ['.empty.dart'] }
    auto_apply: root_package
    runs_before: ['flutter_app_agree_annimation|router_builder']
    build_to: source
```

(2)、在注解解析的过程中，我们对@AgreeRoute注解的代码，我们先返回null，对于我们@AgreeRouter（）注解过的代码，我们返回写入映射文件。

~~~dart
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

///生成AgreeRouter逻辑
class RouterGenerator extends GeneratorForAnnotation<AgreeRouter> {
  RouteParser routeParser() {
    return RouteParseGenerator.routeParser;
  }

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    return RouterWriter(routeParser()).write();
  }
}
~~~

3、（这里的@AgreeRouter 注解是针对使用者做的进一步封装）

使用的时候我们需要在我们的项目中先加入自己的路由文件，如下所示：

~~~dart
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
~~~

## <u>模板文件</u>

我们生成的映射文件是什么样子的呢？这里需要我们自定义模板了，这里附上自己的模板：

~~~dart
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
~~~

我们最后会生成一个类似这样的文件，routeMap中保存着我们的映射路径（注解的url，映射到的类），createInstance含有我们传递的一些参数。

## <u>使用规范</u>

1、我们的库中包含两个注解 @AgreeRoute（） 用于注解你需要注解的类，

@AgreeRouter（）用于注解你项目中自己的进一步的封装。

2、注解中的url 需要符合以下规范：

~~~dart
@AgreeRoute(url:"agree://flutter/pageA")
~~~

url的scheme 必须是agree，

url的host必须是flutter

url必须是两级的

3、获取我们定义过的注解的类的方法如下：

~~~dart
MyArouter().getPage('agree://flutter/pageA')
~~~

MyArouter（）是我们工程中进一步封装的路由类，使用起来会方便。

getPage（）方法中传进去url，就可以获取我们注解的实例.

4、使用前需要在项目的pubspec.yaml中加入以下三方依赖

~~~dart
mustache4dart: ^3.0.0-dev.0.0
  build_runner: ^0.9.1
  source_gen: ^0.8.0
~~~

5、具体的实例可以参考上述的示例工程

注  agreerouter目录是基于source_gen 封装的注解库，使用的时候拷贝到你的工程目录下，注意更改包名！

​     example目录是使用示例，将MyArouter.dart文件拷贝到项目中后，

执行如下命令： 

~~~dart
flutter packages pub run build_runner build
~~~

会生成MyArouter.internal.dart文件 该文件就是我们要的映射文件

## <u>后续补充</u>
