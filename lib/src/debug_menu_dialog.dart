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

  late bool _isProxyEnabled;

  @override
  void initState() {
    super.initState();
    _isProxyEnabled = widget.isProxyEnabled ?? false;
    _ipController.text = widget.proxyIp ?? '';
    _portController.text = widget.proxyPort ?? '8888';
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
              if (widget.envs != null && widget.envs!.isNotEmpty) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '环境切换',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...widget.envs!.map((e) {
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
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],

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
                            onChanged:
                                (value) => setState(() {
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
