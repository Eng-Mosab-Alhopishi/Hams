class SizeFormatter {
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    
    double res = bytes.toDouble();
    int unitIndex = 0;
    while(res >= 1024 && unitIndex < suffixes.length - 1) {
      res /= 1024;
      unitIndex++;
    }
    
    return "${res.toStringAsFixed(decimals)} ${suffixes[unitIndex]}";
  }
}
