import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_monaco/src/platform/platform_webview.dart';
import 'package:flutter_monaco/src/platform/web_view_controller/web_view_controller.dart'
    as base;

// Export the interface so consumers can use it
export 'platform_webview_interface.dart';

/// Factory for creating platform-specific controllers
class PlatformWebViewFactory {
  /// Overrides controller creation in tests.
  @visibleForTesting
  static PlatformWebViewController Function()? debugCreateOverride;

  /// Creates a new platform web view controller.
  ///
  /// Returns the appropriate platform web view controller based on the platform.
  static PlatformWebViewController createController() {
    final override = debugCreateOverride;
    if (override != null) {
      return override();
    }

    return WebViewController();
  }
}

/// A [PlatformWebViewController] that just forwards to the base [WebViewController].
///
/// This hides away the platform-specific details and provides a consistent interface.
class WebViewController implements PlatformWebViewController {
  /// Creates a new [WebViewController] that forwards to the base [WebViewController].
  WebViewController() : _controller = base.WebViewController();

  final base.WebViewController _controller;

  @override
  Widget get widget => _controller.widget;

  @override
  Future<void> initialize() => _controller.initialize();

  @override
  Future<void> load({String? customCss, bool allowCdnFonts = false}) {
    return _controller.load(
      customCss: customCss,
      allowCdnFonts: allowCdnFonts,
    );
  }

  @override
  void dispose() {
    return _controller.dispose();
  }

  @override
  Future<void> enableJavaScript() => _controller.enableJavaScript();

  @override
  Future<Object?> addJavaScriptChannel(
    String name,
    void Function(String p1) onMessage,
  ) {
    return _controller.addJavaScriptChannel(name, onMessage);
  }

  @override
  Future<Object?> removeJavaScriptChannel(String name) {
    return _controller.removeJavaScriptChannel(name);
  }

  @override
  Future<Object?> runJavaScript(String script) {
    return _controller.runJavaScript(script);
  }

  @override
  Future<Object?> runJavaScriptReturningResult(String script) {
    return _controller.runJavaScriptReturningResult(script);
  }

  @override
  Future<void> setBackgroundColor(Color color) =>
      _controller.setBackgroundColor(color);
}

/// Parses WebView2 ExecuteScript results, preserving JSON-like strings.
Object? parseWindowsScriptResult(Object? result) {
  if (result is! String) return result;

  final trimmed = result.trim();
  if (trimmed.isEmpty) return result;

  if (trimmed == 'null') return null;

  if (trimmed.length >= 2 && trimmed.startsWith('"') && trimmed.endsWith('"')) {
    try {
      return json.decode(trimmed);
    } catch (_) {
      return trimmed.substring(1, trimmed.length - 1);
    }
  }

  return result;
}
