import 'safe_js_web.dart' if (dart.library.io) 'safe_js_stub.dart';

abstract class SafeJs {
  static void openUrl(String url) {
    SafeJsPlatform.openUrl(url);
  }
}
