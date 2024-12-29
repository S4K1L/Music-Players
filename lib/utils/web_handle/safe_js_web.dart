import 'dart:html' as html;

class SafeJsPlatform {
  static void openUrl(String url) {
    html.window.open(url, '_blank');
  }
}
