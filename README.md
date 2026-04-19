# Hams (همس) 📡 | Secure Offline Steganography & Data-over-Text Messenger

![Flutter](https://img.shields.io/badge/Made_with-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Open Source](https://img.shields.io/badge/Open_Source-❤️-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-All_Rights_Reserved-red?style=for-the-badge)

[العربية](#العربية) | [English](#english)

---

## العربية

**همس (Hams)** هو تطبيق Flutter متطور مصمم لنقل الوسائط (الصور والصوتيات) عبر قنوات الاتصال النصية فقط. يقوم التطبيق بتحويل الملفات إلى كتل نصية مشفرة (Data-over-Text) باستخدام تقنيات إخفاء المعلومات (Steganography) والضغط الذكي، مما يسمح لك بإرسال الصور والصوتيات عبر الـ SMS أو واتساب بدون الحاجة لإنترنت عالي السرعة.

### 🎯 من يستخدم هذا التطبيق؟ (Target Audience)
هذا التطبيق هو أداة نجاة وتواصل مثالية للفئات التالية:
1. **في مناطق ضعف أو انقطاع الإنترنت:** للأشخاص الذين يمتلكون باقات رسائل نصية (SMS) أو باقات واتساب مجانية فقط ويريدون إرسال صور أو رسائل صوتية هامة.
2. **الصحفيون والنشطاء:** لتجاوز الرقابة أو حظر مشاركة الوسائط على بعض الشبكات من خلال تمريرها كنصوص عشوائية.
3. **عشاق الخصوصية والأمن السيبراني:** لمن يفضلون تشفير وسائطهم وعدم ترك أثر لها في خوادم التطبيقات (الصورة تنتقل كنص ولا يتعرف عليها الخادم كصورة).
4. **المطورون والهاكرز الأخلاقيون:** كنموذج عملي (Proof of Concept) لكيفية استغلال بروتوكولات النصوص لنقل البيانات الثنائية (Binary Data).

### ✨ المميزات الرئيسية
- 🖼️ **تشفير الصور (Image to Text)**: تحويل الصور الملونة إلى رسائل نصية قابلة للنسخ مع الحفاظ على وضوح المعالم.
- 🎙️ **تشفير الصوت (Audio to Text)**: ضغط الرسائل الصوتية (بصيغة Opus) وتحويلها لنصوص قابلة للمشاركة.
- 📉 **محرك ضغط ذكي (Smart Compression)**: خوارزمية بحث ثنائي (Binary Search) تضمن مطابقة حجم الصورة لقيود الواتساب (14.9KB) لتُرسل في رسالة واحدة قدر الإمكان.
- 🧲 **التقاط ذكي من الحافظة (Smart Clipboard)**: دمج تلقائي وسحري للرسائل المجزأة بمجرد نسخها من الواتساب.
- 🎨 **واجهة زجاجية (Glassmorphic UI)**: تصميم عصري فائق الفخامة (OLED Dark Mode) مستوحى من لغة One UI 2026.
- 🌍 **ثنائي اللغة**: دعم كامل واحترافي للعربية والإنجليزية.

### 🚀 كيف يعمل؟
1. **التشفير:** اختر صورة أو سجل مقطعاً صوتياً، سيقوم المحرك بضغطه لأقصى حد وتحويله لنص مشفر (Base64/Base85).
2. **المشاركة:** انسخ النص وأرسله كرسالة عادية عبر (WhatsApp, SMS, Telegram).
3. **الاستعادة:** يقوم المستلم بتحديد الرسالة في الواتساب ونسخها. بمجرد فتح تطبيق  **همس**-- **شاشة استعادة**، سيلتقط النص، يفك تشفيره، ويعرض الصورة أو يشغل الصوت فوراً!

---

## English

**Hams (Whisper)** is an advanced Flutter application designed for transmitting media (images and audio) over text-only communication channels. By utilizing steganography and aggressive smart compression (Data-over-Text), Hams converts files into encrypted text blocks, allowing you to send media via SMS or text-only WhatsApp bundles without requiring high-speed internet.

### 🎯 Who is this for? (Use Cases)
This app is a vital communication and survival tool for:
1. **Low-Bandwidth & Offline Areas:** People who only have access to SMS or free text-only WhatsApp bundles and urgently need to send images or voice notes.
2. **Journalists & Activists:** To bypass network throttling, censorship, or media-sharing blocks by disguising media as random text strings.
3. **Privacy & Cybersecurity Enthusiasts:** For those who want zero-trace media sharing. Servers only see text strings, completely unaware that an image is being transmitted.
4. **Developers & Tech Enthusiasts:** As a Proof of Concept (PoC) for extreme data compression, payload chunking, and binary-to-text routing.

### ✨ Key Features
- 🖼️ **Image to Text Encoding**: Convert color images into copiable text chunks while preserving recognizable fidelity.
- 🎙️ **Audio to Text Encoding**: Compress voice messages (Opus codec) into shareable text blocks.
- 📉 **Smart Compression Engine**: Uses a Binary Search algorithm and WebP conversion to fit payloads perfectly into WhatsApp's message limits (14.9KB) to guarantee a 1-message delivery when possible.
- 🧲 **Smart Clipboard Reassembly**: Instantly detects, parses, and reassembles fragmented chunks copied from WhatsApp.
- 🎨 **Glassmorphic UI**: Ultra-premium OLED dark mode design inspired by the upcoming One UI 2026 guidelines.
- 🌍 **Bilingual**: Seamless English and Arabic localization.

### 🚀 How it Works?
1. **Encode:** Pick an image or record audio. The engine aggressively compresses it and converts it into a dense Base64/Base85 text payload.
2. **Share:** Copy the payload and paste it into any text messenger (WhatsApp, SMS).
3. **Decode:** The recipient highlights and copies the text messages. Upon opening **Hams** -- **Restore Screen**, the app instantly reads the clipboard, reassembles the chunks, and reveals the media!

---

## 🛠️ Technology Stack
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Architecture**: Clean Architecture / Feature-Based
- **Compression**: `flutter_image_compress` (WebP) & Zlib
- **Concurrency**: Heavy image quantization offloaded to background `Isolates` (`compute`).

## 📥 Installation
Ready-to-use APKs are available in the **[Releases](https://github.com/USER_NAME/hams/releases)** section.

---
*Developed with ❤️ by Mosab_Soft for the digital privacy and offline communication community.*
