enum HamsError {
  imageTooLarge,
  encodingFailed,
  corruptedChunk,
  missingChunks,
  decompressionFailed,
  invalidPayload,
}

extension HamsErrorExtension on HamsError {
  String get message {
    return "Error"; 
  }

  String translate(String locale) {
    if (locale == 'en') {
      switch (this) {
        case HamsError.imageTooLarge: return "File is too large! Maximum limit is 5MB.";
        case HamsError.encodingFailed: return "Process failed. Please try again.";
        case HamsError.corruptedChunk: return "This chunk appears to be corrupted.";
        case HamsError.missingChunks: return "Some chunks are missing.";
        case HamsError.decompressionFailed: return "Data expansion failed.";
        case HamsError.invalidPayload: return "This is not a valid Hams payload.";
      }
    } else {
      switch (this) {
        case HamsError.imageTooLarge: return "الملف كبير جداً! الحد الأقصى هو 5 ميجابايت.";
        case HamsError.encodingFailed: return "فشلت العملية. يرجى المحاولة مرة أخرى.";
        case HamsError.corruptedChunk: return "يبدو أن هذا الجزء تالف.";
        case HamsError.missingChunks: return "بعض الأجزاء مفقودة.";
        case HamsError.decompressionFailed: return "فشل فك الضغط. قد يكون المحتوى ناقصاً.";
        case HamsError.invalidPayload: return "هذا ليس محتوى همس صالح.";
      }
    }
  }
}
