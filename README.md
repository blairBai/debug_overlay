# Debug Overlay

一个用于Flutter应用的调试工具覆盖层，提供环境切换、代理配置等功能。

## 功能特性

- 🌍 **环境切换**: 支持多环境配置和快速切换
- ➕ **自定义环境**: 可以动态添加、删除环境配置
- 🔧 **代理配置**: 支持HTTP代理设置，用于抓包调试
- 🎯 **强制登录**: 支持模拟登录/跳转功能
- 🎨 **自定义扩展**: 支持添加自定义底部组件

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  debug_overlay: ^1.0.0
```

## 使用方法

### 基本用法

```dart
import 'package:debug_overlay/debug_overlay.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DebugOverlayController _debugController;
  String _currentEnv = 'https://dev.example.com';

  @override
  void initState() {
    super.initState();
    _debugController = DebugOverlayController(
      currentEnvUrl: _currentEnv,
      onEnvSwitch: (String newEnv) {
        setState(() {
          _currentEnv = newEnv;
        });
        // 重启应用或重新初始化网络配置
      },
      isProxyEnabled: false,
      proxyIp: '127.0.0.1',
      proxyPort: '8888',
      onSaveProxyConfig: (String ip, String port, bool enabled) {
        // 保存代理配置
        print('代理配置已更新: $ip:$port, 启用状态: $enabled');
      },
      onForceLogin: () {
        // 执行强制登录逻辑
        print('执行强制登录');
      },
    );
  }

  @override
  void dispose() {
    _debugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Overlay Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('当前环境: $_currentEnv'),
            ElevatedButton(
              onPressed: () => _debugController.show(context),
              child: Text('显示调试菜单'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 环境管理

#### 默认环境

如果不提供 `envs` 参数，Debug Overlay 将使用以下默认环境：

- 开发环境: `https://dev.example.com`
- 测试环境: `https://test.example.com`
- 预发布环境: `https://staging.example.com`

#### 自定义环境

```dart
_debugController = DebugOverlayController(
  currentEnvUrl: 'https://custom-dev.com',
  envs: [
    ('自定义开发', 'https://custom-dev.com'),
    ('自定义测试', 'https://custom-test.com'),
    ('生产环境', 'https://prod.com'),
  ],
  onEnvSwitch: (String newEnv) {
    // 处理环境切换
  },
  onEnvsChanged: (List<(String, String)> newEnvs) {
    // 处理环境列表变化（添加/删除环境后）
    print('环境列表已更新: ${newEnvs.length} 个环境');
  },
);
```

#### 环境变化回调

当用户通过调试菜单添加或删除环境时，会触发 `onEnvsChanged` 回调：

```dart
onEnvsChanged: (List<(String, String)> newEnvs) {
  // 保存新的环境列表到本地存储
  _saveEnvsToStorage(newEnvs);
  
  // 更新应用状态
  setState(() {
    _currentEnvs = newEnvs;
  });
  
  // 显示提示信息
  showSnackBar('环境列表已更新');
},
```

#### 动态环境管理

用户可以通过调试菜单动态添加和删除环境：

1. 点击环境切换区域的 "+" 按钮添加新环境
2. 点击环境项右侧的删除图标删除环境
3. 所有更改都会实时反映在界面上

### 代理配置

```dart
_debugController = DebugOverlayController(
  isProxyEnabled: true,
  proxyIp: '127.0.0.1',
  proxyPort: '8888',
  onSaveProxyConfig: (String ip, String port, bool enabled) {
    // 保存代理配置到本地存储或配置中心
    _saveProxyConfig(ip, port, enabled);
  },
);
```

### 自定义组件

```dart
_debugController = DebugOverlayController(
  bottomWidgets: [
    ElevatedButton(
      onPressed: () => _customAction(),
      child: Text('自定义操作'),
    ),
    Divider(),
    Text('自定义说明文字'),
  ],
);
```

## API 参考

### DebugOverlayController

#### 构造函数参数

| 参数 | 类型 | 说明 |
|------|------|------|
| `currentEnvUrl` | `String?` | 当前环境URL |
| `envs` | `List<(String, String)>?` | 环境配置列表 |
| `onEnvSwitch` | `Function(String)?` | 环境切换回调 |
| `isProxyEnabled` | `bool?` | 代理是否启用 |
| `proxyIp` | `String?` | 代理IP地址 |
| `proxyPort` | `String?` | 代理端口 |
| `onSaveProxyConfig` | `Function(String, String, bool)?` | 保存代理配置回调 |
| `onForceLogin` | `Function()?` | 强制登录回调 |
| `bottomWidgets` | `List<Widget>?` | 底部自定义组件 |
| `onEnvsChanged` | `Function(List<(String, String)>)?` | 环境列表变化回调 |

#### 方法

| 方法 | 说明 |
|------|------|
| `show(BuildContext context)` | 显示调试覆盖层 |
| `hide()` | 隐藏调试覆盖层 |
| `dispose()` | 释放资源 |

## 注意事项

1. **环境切换**: 环境切换后通常需要重启应用或重新初始化网络配置
2. **代理配置**: 代理配置更改后需要保存到本地存储或配置中心
3. **状态管理**: 环境列表现在由组件内部管理，外部传入的 `envs` 仅作为初始值
4. **内存管理**: 记得在不需要时调用 `dispose()` 方法释放资源

## 更新日志

### v1.0.0
- 初始版本发布
- 支持环境切换、代理配置等基本功能

### v1.1.0
- 新增内部状态管理环境列表
- 支持动态添加、删除环境
- 改进用户界面和交互体验

## 许可证

MIT License

