import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'debug_menu_dialog.dart';

class DebugOverlayController {
  static DebugOverlayController? _instance;

  factory DebugOverlayController({
    String? currentEnvUrl,
    List<(String, String)>? envs,
    void Function(String env)? onEnvSwitch,
    bool? isProxyEnabled,
    String? proxyIp,
    String? proxyPort,
    void Function(String ip, String port, bool enabled)? onSaveProxyConfig,
    void Function()? onForceLogin,
    Widget? customDialog,
    List<Widget>? bottomWidgets,
  }) {
    _instance ??= DebugOverlayController._internal(
      currentEnvUrl: currentEnvUrl,
      envs: envs,
      onEnvSwitch: onEnvSwitch,
      isProxyEnabled: isProxyEnabled,
      proxyIp: proxyIp,
      proxyPort: proxyPort,
      onSaveProxyConfig: onSaveProxyConfig,
      onForceLogin: onForceLogin,
      customDialog: customDialog,
      bottomWidgets: bottomWidgets,
    );
    return _instance!;
  }

  DebugOverlayController._internal({
    this.currentEnvUrl,
    this.envs,
    this.onEnvSwitch,
    this.isProxyEnabled,
    this.proxyIp,
    this.proxyPort,
    this.onSaveProxyConfig,
    this.onForceLogin,
    this.customDialog,
    this.bottomWidgets,
  });

  OverlayEntry? _entry;
  bool _isShown = false;
  // 初始化属性
  String? currentEnvUrl;
  List<(String, String)>? envs;
  bool? isProxyEnabled;
  String? proxyIp;
  String? proxyPort;
  void Function(String env)? onEnvSwitch;
  void Function(String ip, String port, bool enabled)? onSaveProxyConfig;
  void Function()? onForceLogin;
  Widget? customDialog;
  List<Widget>? bottomWidgets;

  void show(BuildContext context) {
    // debug 模式下不显示 -> 由外部控制
    // if (!kDebugMode || _isShown) return;
    if (_isShown) return;

    _isShown = true;
    _entry = OverlayEntry(
      builder:
          (_) => _DebugOverlayButton(
            onTap: () async {
              if (_entry != null) {
                hide();
              }

              if (!context.mounted) return;
              await showDialog(
                context: context,
                builder:
                    (_) =>
                        customDialog ??
                        DebugMenuDialog(
                          currentEnvUrl: currentEnvUrl,
                          envs: envs,
                          onEnvSwitch: (env) {
                            currentEnvUrl = env;
                            onEnvSwitch?.call(env);
                          },
                          isProxyEnabled: isProxyEnabled,
                          proxyIp: proxyIp,
                          proxyPort: proxyPort,
                          onSaveProxyConfig: (ip, port, enabled) {
                            isProxyEnabled = enabled;
                            proxyIp = ip;
                            proxyPort = port;
                            onSaveProxyConfig?.call(ip, port, enabled);
                          },
                          onForceLogin: onForceLogin,
                          bottomWidgets: bottomWidgets,
                        ),
              );

              // 弹窗关闭后重新显示按钮
              if (context.mounted) {
                show(context);
              }
            },
          ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Overlay.of(context, rootOverlay: true).insert(_entry!);
      } else {
        _entry = null;
        _isShown = false;
      }
    });
  }

  void hide() {
    _entry?.remove();
    _entry = null;
    _isShown = false;
  }

  void dispose() {
    hide();
    _instance = null;
  }
}

class _DebugOverlayButton extends StatefulWidget {
  final VoidCallback onTap;

  const _DebugOverlayButton({required this.onTap});

  @override
  State<_DebugOverlayButton> createState() => _DebugOverlayButtonState();
}

class _DebugOverlayButtonState extends State<_DebugOverlayButton> {
  double _right = 16;
  double _bottom = 32;

  final double _buttonSize = 48.0;
  final double _padding = 8.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      right: _right,
      bottom: _bottom,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _right -= details.delta.dx;
            _bottom -= details.delta.dy;

            _right = _right.clamp(0.0, screenSize.width - _buttonSize);
            _bottom = _bottom.clamp(0.0, screenSize.height - _buttonSize);
          });
        },
        onPanEnd: (_) {
          setState(() {
            final center = screenSize.width / 2;
            _right =
                (_right + _buttonSize / 2) < center
                    ? _padding // 吸左
                    : screenSize.width - _buttonSize - _padding; // 吸右
          });
        },
        onTap: widget.onTap,
        child: Material(
          color: Colors.transparent,
          child: FloatingActionButton(
            mini: true,
            heroTag: 'debug-btn',
            onPressed: null,
            child: const Icon(Icons.bug_report),
          ),
        ),
      ),
    );
  }
}
