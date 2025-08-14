import 'package:debug_overlay/src/string_toast_extension.dart';
import 'package:flutter/material.dart';

class DebugMenuDialog extends StatefulWidget {
  final String? currentEnvUrl;
  final List<(String, String)>? envs;
  final void Function(String env)? onEnvSwitch;
  final bool? isProxyEnabled;
  final String? proxyIp;
  final String? proxyPort;
  final void Function(String ip, String port, bool enabled)? onSaveProxyConfig;
  final void Function()? onForceLogin;
  final List<Widget>? bottomWidgets;

  const DebugMenuDialog({
    super.key,
    this.currentEnvUrl,
    this.envs,
    this.onEnvSwitch,
    this.isProxyEnabled,
    this.proxyIp,
    this.proxyPort,
    this.onSaveProxyConfig,
    this.onForceLogin,
    this.bottomWidgets,
  });

  @override
  State<DebugMenuDialog> createState() => _DebugMenuDialogState();
}

class _DebugMenuDialogState extends State<DebugMenuDialog> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _envNameController = TextEditingController();
  final _envUrlController = TextEditingController();

  late bool _isProxyEnabled;
  late List<(String, String)> _envs;

  @override
  void initState() {
    super.initState();
    _isProxyEnabled = widget.isProxyEnabled ?? false;
    _ipController.text = widget.proxyIp ?? '';
    _portController.text = widget.proxyPort ?? '8888';
    // 初始化环境列表，如果外部传入为空则使用默认环境
    _envs = widget.envs?.toList() ??
        [
          ('开发环境', 'https://dev.example.com'),
          ('测试环境', 'https://test.example.com'),
          ('预发布环境', 'https://staging.example.com'),
        ];
  }

  @override
  void dispose() {
    _envNameController.dispose();
    _envUrlController.dispose();
    super.dispose();
  }

  // Functions
  bool validateProxy(String ip, String port) {
    RegExp reip = RegExp(
      r'^(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)$',
    );
    bool isValidIP = reip.hasMatch(ip);
    if (!isValidIP) {
      '请输入有效IP地址'.showToast(context);
      return false;
    }

    RegExp report = RegExp(r'^[0-9]{4}$');
    bool isValidPort = report.hasMatch(port);
    if (!isValidPort) {
      '请输入有效端口'.showToast(context);
      return false;
    }

    return true;
  }

  bool validateEnv(String name, String url) {
    if (name.trim().isEmpty) {
      '请输入环境名称'.showToast(context);
      return false;
    }
    if (url.trim().isEmpty) {
      '请输入环境URL'.showToast(context);
      return false;
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      '请输入有效的URL地址'.showToast(context);
      return false;
    }
    return true;
  }

  void _addNewEnv() {
    _envNameController.clear();
    _envUrlController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Center(
            child: Text(
              '添加环境',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _envNameController,
                decoration: const InputDecoration(
                  labelText: '环境名称',
                  hintText: '例如：开发环境',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _envUrlController,
                decoration: const InputDecoration(
                  labelText: '环境URL',
                  hintText: '例如：https://dev.example.com',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _envNameController.text.trim();
                final url = _envUrlController.text.trim();

                if (validateEnv(name, url)) {
                  setState(() {
                    _envs.add((name, url));
                  });
                  Navigator.of(context).pop();
                  '环境添加成功'.showToast(context);
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEnv(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Center(
            child: Text(
              '确认删除',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ),
          content: Text(
            '确定要删除环境"${_envs[index].$1}"吗？',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _envs.removeAt(index);
                });
                Navigator.of(context).pop();
                '环境删除成功'.showToast(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  // Widgets
  void showEnvSwitchDialog(
    BuildContext context,
    String envUrl,
    VoidCallback onRestart,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Center(
            child: Text(
              '提示',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ),
          content: Text(
            '切换环境：$envUrl\n需要重启应用,是否重启?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      '取消',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRestart();
                    },
                    child: const Text(
                      '重启',
                      style: TextStyle(fontSize: 16, color: Color(0xFF007AFF)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnvItem(
    String title,
    String url,
    bool selected,
    void Function((String, String)) onTap,
    int index,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                url,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Checkbox(
          value: selected,
          onChanged: (_) => onTap((title, url)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
          onPressed: () => _deleteEnv(index),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: const Text(
                  '测试工具',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // 环境切换
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '环境切换',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _addNewEnv,
                          icon: const Icon(Icons.add, color: Colors.blue),
                          tooltip: '添加环境',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ..._envs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final e = entry.value;
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildEnvItem(
                            e.$1,
                            e.$2,
                            e.$2 == widget.currentEnvUrl,
                            (env) {
                              if (env.$2 == widget.currentEnvUrl) return;
                              showEnvSwitchDialog(context, env.$2, () {
                                widget.onEnvSwitch?.call((env.$2));
                                Navigator.of(context).pop();
                              });
                            },
                            index,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 抓包配置
              if (widget.isProxyEnabled != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '代理/抓包',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _isProxyEnabled ? '开启中' : '未开启',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          Switch(
                            value: _isProxyEnabled,
                            onChanged: (value) => setState(() {
                              _isProxyEnabled = value;
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // 输入框
                      Row(
                        children: [
                          const Text('IP  : ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: TextField(
                              controller: _ipController,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                border: UnderlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Port: ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: TextField(
                              controller: _portController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                border: UnderlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '变更代理地址或端口号后\n请点击保存使配置生效~',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),

                      // 保存按钮
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            final ip = _ipController.text.trim();
                            final port = _portController.text.trim();
                            if (!validateProxy(ip, port)) return;
                            // print('保存代理配置：$ip:$port  开启状态：$_isProxyEnabled');
                            widget.onSaveProxyConfig?.call(
                              ip,
                              port,
                              _isProxyEnabled,
                            );
                            Navigator.of(context).pop(); // 关闭弹窗
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: const Text('保存代理配置'),
                        ),
                      ),

                      if (widget.onForceLogin != null) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onForceLogin?.call();
                            },
                            child: const Text('模拟登录/跳转'),
                          ),
                        ),
                      ],
                      ...?widget.bottomWidgets,
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
