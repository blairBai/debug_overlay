import 'package:flutter/material.dart';
import 'package:debug_overlay/debug_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Overlay Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Debug Overlay Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DebugOverlayController _debugController;
  String _currentEnv = 'https://dev.example.com';
  bool _isProxyEnabled = false;
  String _proxyIp = '127.0.0.1';
  String _proxyPort = '8888';
  List<(String, String)> _currentEnvs = [
    ('开发环境', 'https://dev.example.com'),
    ('测试环境', 'https://test.example.com'),
    ('预发布环境', 'https://staging.example.com'),
  ];

  @override
  void initState() {
    super.initState();
    _debugController = DebugOverlayController(
      currentEnvUrl: _currentEnv,
      envs: _currentEnvs,
      onEnvSwitch: (String newEnv) {
        setState(() {
          _currentEnv = newEnv;
        });
        // 显示环境切换提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('环境已切换到: $newEnv'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onEnvsChanged: (List<(String, String)> newEnvs) {
        setState(() {
          _currentEnvs = newEnvs;
        });
        // 显示环境列表变化提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('环境列表已更新，当前共有 ${newEnvs.length} 个环境'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      isProxyEnabled: _isProxyEnabled,
      proxyIp: _proxyIp,
      proxyPort: _proxyPort,
      onSaveProxyConfig: (String ip, String port, bool enabled) {
        setState(() {
          _proxyIp = ip;
          _proxyPort = port;
          _isProxyEnabled = enabled;
        });
        // 保存代理配置到本地存储
        _saveProxyConfig(ip, port, enabled);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('代理配置已保存: $ip:$port, 启用状态: $enabled'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onForceLogin: () {
        // 执行强制登录逻辑
        _performForceLogin();
      },
      bottomWidgets: [
        const Divider(height: 1),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.info, color: Colors.blue, size: 16),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                '这是一个自定义的底部组件示例',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _showCustomAction(),
          icon: const Icon(Icons.settings),
          label: const Text('自定义操作'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debugController.dispose();
    super.dispose();
  }

  void _saveProxyConfig(String ip, String port, bool enabled) {
    // 这里可以保存到 SharedPreferences 或其他存储
    print('保存代理配置: $ip:$port, 启用状态: $enabled');
  }

  void _performForceLogin() {
    // 模拟强制登录过程
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('强制登录'),
        content: const Text('正在执行强制登录...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showCustomAction() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义操作'),
        content: const Text('这是一个自定义操作的示例，你可以在这里添加任何你需要的功能。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.bug_report,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Debug Overlay 演示应用',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                '当前环境: $_currentEnv',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '环境数量: ${_currentEnvs.length}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '代理状态: ${_isProxyEnabled ? "启用" : "禁用"}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              if (_isProxyEnabled) ...[
                const SizedBox(height: 4),
                Text(
                  '代理地址: $_proxyIp:$_proxyPort',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _debugController.show(context),
                icon: const Icon(Icons.bug_report),
                label: const Text('显示调试菜单'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '点击右上角的浮动按钮或使用上面的按钮来显示调试菜单',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      '功能说明',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 环境切换：支持多环境配置和快速切换\n'
                      '• 自定义环境：可以动态添加、删除环境配置\n'
                      '• 代理配置：支持HTTP代理设置，用于抓包调试\n'
                      '• 强制登录：支持模拟登录/跳转功能\n'
                      '• 自定义扩展：支持添加自定义底部组件',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      '新功能亮点',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '✨ 内部状态管理环境列表\n'
                      '✨ 动态添加/删除环境配置\n'
                      '✨ 智能环境验证\n'
                      '✨ 改进的用户界面\n'
                      '✨ 完全向后兼容',
                      style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
