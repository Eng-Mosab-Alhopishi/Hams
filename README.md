# Hams (GhostDrop) - 📡 Secure Steganography Messenger

[العربية](#العربية) | [English](#english)

---

## العربية

**Hams** (المعروف سابقاً بـ GhostDrop) هو تطبيق Flutter متطور يسمح لك بمشاركة الصور والملفات الصوتية عبر الرسائل النصية المباشرة من خلال تحويلها إلى قطع مشفرة صغيرة. يستخدم التطبيق خوارزميات ضغط ذكية وبحث ثنائي لضمان أقل عدد ممكن من الرسائل مع الحفاظ على جودة فائقة.

### ✨ المميزات الرئيسية
- 🖼️ **تشفير الصور**: تحويل الصور إلى رسائل نصية قابلة للنسخ والمشاركة.
- 🎙️ **تشفير الصوت**: دعم كامل لتشفير الملفات الصوتية.
- 📉 **محرك ضغط ذكي**: استخدام تنسيق WebP مع خوارزمية بحث ثنائي (Binary Search) لتقليص الحجم لأقصى حد.
- 🎨 **واجهة زجاجية (Glassmorphic UI)**: تصميم عصري مستوحى من لغة One UI 2026 مع تأثيرات زجاجية وحركية سلسة.
- 🌓 **دعم الوضع الداكن والفاتح**: واجهة متكيفة تماماً مع سمات النظام.
- 🌍 **ثنائي اللغة**: دعم كامل للعربية والإنجليزية.

### 🚀 كيف يعمل؟
1. **التشفير**: اختر صورة أو مقطعاً صوتياً، سيقوم التطبيق بضغطها وتقسيمها إلى أجزاء (Chunks) نصية.
2. **المشاركة**: انسخ هذه الأجزاء وأرسلها عبر أي منصة (واتساب، تيليجرام، رسائل نصية).
3. **الاستعادة**: سيقوم المستلم بنسخ الرسائل، وسيقوم تطبيق Hams بالتقاطها تلقائياً من الحافظة وإعادة تجميعها فوراً.

---

## English

**Hams** (formerly GhostDrop) is a cutting-edge Flutter application that enables you to share images and audio files via direct text messages by converting them into small encrypted chunks. The app utilizes smart compression and binary search algorithms to ensure the minimum number of messages while maintaining high quality.

### ✨ Key Features
- 🖼️ **Image Encoding**: Convert images into copiable text chunks.
- 🎙️ **Audio Encoding**: Full support for encoding audio files.
- 📉 **Smart Compression Engine**: Utilizes WebP format with a Binary Search algorithm for maximum size reduction.
- 🎨 **Glassmorphic UI**: Modern design inspired by One UI 2026 with smooth glass blur and animations.
- 🌓 **Dark & Light Mode Support**: Fully adaptive interface.
- 🌍 **Bilingual**: Full Arabic and English support.

### 🚀 How it Works?
1. **Encoding**: Pick an image or audio, and the app will compress and split it into text chunks.
2. **Sharing**: Copy these chunks and send them over any platform (WhatsApp, Telegram, SMS).
3. **Recovery**: The recipient copies the messages, and Hams automatically captures them from the clipboard and reassembles them instantly.

---

## 🛠️ Technology Stack
- **Framework**: Flutter
- **State Management**: Riverpod
- **Architecture**: Clean Architecture (Feature-based)
- **Encryption Logic**: Base64 + Adaptive Floor Binary Search
- **Image Processing**: WebP encoding @ 35% Quality (Default)

## 📥 Installation
You can find the ready-to-use APKs in the **[Releases](https://github.com/USER_NAME/hams/releases)** section.

---
*Created with ❤️ for the security and privacy community.*
