import 'dart:io';

bool Boolean(String key, {bool fallback = false}) {
  try {
    return bool.parse(Platform.environment[key] ?? "");
  } catch (_) {
    return fallback;
  }
}

class vars {
  static const AutoIdentifyMedia = "RETROVIBED_MEDIA_AUTO_IDENTIFY";
}
