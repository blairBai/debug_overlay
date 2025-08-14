import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debug_overlay/src/debug_menu_dialog.dart';

void main() {
  group('DebugMenuDialog Tests', () {
    testWidgets('should display default environments when no envs provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebugMenuDialog(
              currentEnvUrl: 'https://dev.example.com',
            ),
          ),
        ),
      );

      // 应该显示默认环境
      expect(find.text('开发环境'), findsOneWidget);
      expect(find.text('测试环境'), findsOneWidget);
      expect(find.text('预发布环境'), findsOneWidget);
    });

    testWidgets('should display custom environments when provided',
        (WidgetTester tester) async {
      final customEnvs = [
        ('Custom Dev', 'https://custom-dev.com'),
        ('Custom Test', 'https://custom-test.com'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebugMenuDialog(
              currentEnvUrl: 'https://custom-dev.com',
              envs: customEnvs,
            ),
          ),
        ),
      );

      // 应该显示自定义环境
      expect(find.text('Custom Dev'), findsOneWidget);
      expect(find.text('Custom Test'), findsOneWidget);
      expect(find.text('开发环境'), findsNothing); // 不应该显示默认环境
    });

    testWidgets('should show add environment button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebugMenuDialog(),
          ),
        ),
      );

      // 应该显示添加环境按钮
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show delete buttons for each environment',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebugMenuDialog(),
          ),
        ),
      );

      // 应该为每个环境显示删除按钮
      expect(find.byIcon(Icons.delete), findsNWidgets(3)); // 3个默认环境
    });

    testWidgets('should open add environment dialog when add button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebugMenuDialog(),
          ),
        ),
      );

      // 点击添加按钮
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 应该显示添加环境对话框
      expect(find.text('添加环境'), findsOneWidget);
      expect(find.text('环境名称'), findsOneWidget);
      expect(find.text('环境URL'), findsOneWidget);
    });

    testWidgets('should add new environment when form is submitted',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebugMenuDialog(),
          ),
        ),
      );

      // 点击添加按钮
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 填写表单
      await tester.enterText(find.byType(TextField).first, 'New Environment');
      await tester.enterText(
          find.byType(TextField).last, 'https://new-env.com');

      // 提交表单
      await tester.tap(find.text('添加'));
      await tester.pumpAndSettle();

      // 应该显示新环境
      expect(find.text('New Environment'), findsOneWidget);
    });

    testWidgets(
        'should show delete confirmation dialog when delete button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebugMenuDialog(),
          ),
        ),
      );

      // 点击第一个删除按钮
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // 应该显示删除确认对话框
      expect(find.text('确认删除'), findsOneWidget);
      expect(find.text('确定要删除环境"开发环境"吗？'), findsOneWidget);
    });
  });
}
