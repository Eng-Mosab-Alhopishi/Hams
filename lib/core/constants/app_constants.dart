class AppConstants {
  static const String imageHeader = 'GD';
  static const String audioHeader = 'GDA';
  static const int maxChunkSize = 19900;             // ✅ Strict limit to guarantee safe WhatsApp direct pasting
  static const int audioChunkSize = 19900;           // ✅ Same
  
  static const int webpQuality = 35;                 // ✅ Reverted — original quality
  static const int maxImageDimension = 1280;         // ✅ Reverted — original quality
  static const int quantizeColors = 256;             // ✅ Reverted — original quality
  static const int zlibLevel = 9;
  
  // Audio Config
  static const int maxRecordingSeconds = 10;
  static const int audioBitRate = 6000;              // ✅ Keep — achieves 1-2 messages
  static const int audioSampleRate = 8000;
  static const int audioChannels = 1;

  static const String version = '1.0.0';
  static const Duration clipboardPollInterval = Duration(milliseconds: 500);
  
  // Regex for detection (Handles both GD and GDA)
  // Optionally supports a 3-character alphanumeric ID between the type and index: e.g., [GD:ab1:1/2] or just [GD:1/2]
  static final RegExp chunkRegExp = RegExp(r'\[(GD|GDA)(?::([a-zA-Z0-9]{3}))?:(\d+)\/(\d+)\]');
}
