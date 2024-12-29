class SafeJsPlatform {
  static void openUrl(String url) {
    throw UnsupportedError("SafeJs is only available on web platforms.");
  }
}
