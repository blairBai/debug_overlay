# Debug Overlay 示例应用

这是一个展示 Debug Overlay 所有功能的示例应用。

## 功能演示

这个示例应用展示了以下功能：

### 🌍 环境管理
- 默认环境配置
- 动态添加新环境
- 删除现有环境
- 环境切换功能
- 环境变化实时回调

### 🔧 代理配置
- 代理开关控制
- IP地址和端口配置
- 配置保存功能

### 🎯 其他功能
- 强制登录模拟
- 自定义底部组件
- 状态管理和回调

## 运行方法

### 1. 安装依赖
```bash
cd example
flutter pub get
```

### 2. 运行应用
```bash
flutter run
```

### 3. 测试功能

#### 显示调试菜单
- 点击主界面上的"显示调试菜单"按钮
- 或者点击右上角的浮动调试按钮

#### 环境管理
- 在调试菜单中，点击环境切换区域的 "+" 按钮添加新环境
- 点击环境项右侧的删除图标删除环境
- 点击环境项的复选框切换环境
- 环境变化会实时回调到主应用，更新界面显示

#### 代理配置
- 在调试菜单中配置代理IP和端口
- 使用开关控制代理启用状态
- 点击"保存代理配置"保存设置

#### 自定义功能
- 查看底部的自定义组件
- 点击"自定义操作"按钮测试功能

## 界面预览

主界面显示：
- 当前环境信息
- 代理状态
- 功能说明
- 新功能亮点

调试菜单包含：
- 环境切换（支持增删改）
- 代理配置
- 强制登录
- 自定义组件

## 代码结构

```
example/lib/main.dart
├── MyApp - 应用入口
├── MyHomePage - 主页面
└── _MyHomePageState - 状态管理
    ├── DebugOverlayController 配置
    ├── 环境状态管理
    ├── 代理配置管理
    └── 自定义功能实现
```

## 关键代码示例

### 初始化 Debug Overlay
```dart
_debugController = DebugOverlayController(
  currentEnvUrl: _currentEnv,
  onEnvSwitch: (String newEnv) {
    setState(() {
      _currentEnv = newEnv;
    });
  },
  isProxyEnabled: _isProxyEnabled,
  proxyIp: _proxyIp,
  proxyPort: _proxyPort,
  onSaveProxyConfig: (String ip, String port, bool enabled) {
    // 处理代理配置保存
  },
  onForceLogin: () {
    // 处理强制登录
  },
  bottomWidgets: [
    // 自定义底部组件
  ],
);
```

### 显示调试菜单
```dart
ElevatedButton.icon(
  onPressed: () => _debugController.show(context),
  icon: const Icon(Icons.bug_report),
  label: const Text('显示调试菜单'),
)
```

## 注意事项

1. **环境切换**: 切换环境后会显示提示，实际应用中需要重启或重新初始化
2. **代理配置**: 配置更改后会立即更新状态，实际应用中需要保存到持久化存储
3. **自定义组件**: 底部组件可以根据需要自定义，支持任何 Widget

## 故障排除

如果遇到问题：

1. 确保已正确安装依赖：`flutter pub get`
2. 检查 Flutter 版本兼容性
3. 查看控制台错误信息
4. 尝试热重载或热重启

## 更多信息

查看主项目的 README.md 了解更多功能说明和 API 文档。
