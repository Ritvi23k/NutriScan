# 🥗 NutriScan

**NutriScan** is an AI-powered calorie tracking application built with Flutter. It helps users effortlessly log their meals, track daily caloric intake, and analyze their nutritional habits over time—with a specialized focus on localized Indian cuisine.

---

## 💡 The Journey Behind NutriScan

As a college student balancing intense academic schedules, lab sessions, and daily routines, staying on top of fitness and nutrition goals can be incredibly challenging. Most mainstream health apps are tailored heavily toward Western diets, making it frustrating to track a traditional meal like a simple homemade lunch. 

NutriScan was born out of a personal mission to bridge this gap. Blending a strong interest in engineering and AI/ML applications with a personal need for accessible wellness tracking, this project transforms calorie tracking into something completely seamless. Instead of guessing portion sizes or typing out complex ingredients, you can simply point your camera, snap a picture, and let artificial intelligence handle the heavy lifting for Indian food items.

---

## ✨ Key Features

- 📸 **Snap & Track**: Simply take a photo of your meal and let AI instantly analyze the food, recognize the item, and estimate its calorie content.
- 🍛 **Indian Food Database**: Built-in support for a vast database of localized food items (e.g., Roti, Dal, Paneer, Biryani, and 35+ other common regional dishes) with macro tracking.
- 📊 **Smart Analytics**: Interactive charts, daily streaks, and a 30-day history view to track calorie distribution over time and keep you motivated.
- 🔐 **Seamless Authentication**: Secure, one-tap Google Sign-In powered by Firebase Authentication that automatically greets you by your name.
- 🌙 **Modern UI/UX**: Premium design aesthetics featuring beautiful fluid typography, clean progress vectors, and a polished user experience.

---

## 🛠️ Technology Stack

NutriScan is built using modern and robust technologies to ensure high performance, scalability, and a great cross-platform experience.

### Framework & Core
- **[Flutter](https://flutter.dev/)**: Cross-platform UI toolkit for natively compiled applications (iOS, Android, Web).
- **Dart**: Core programming language used by Flutter.

### Backend & Authentication
- **[Firebase Authentication](https://firebase.google.com/docs/auth)**: Secure identity management.
- **Google Sign-In**: Easy one-tap login for users across platforms (integrated natively on mobile devices and via Firebase pop-up on Web).

### State Management & Architecture
- **[Provider](https://pub.dev/packages/provider)**: Simple, flexible, and scalable state management solution for reactive data layers.

### Storage & Data
- **[Shared Preferences](https://pub.dev/packages/shared_preferences)**: Used for persisting user session tokens and lightweight local settings between app launches.

### User Interface & Design
- **[Google Fonts](https://pub.dev/packages/google_fonts)**: Utilizing **Outfit** for beautiful headers and **Inter** for highly readable body text.
- **[fl_chart](https://pub.dev/packages/fl_chart)**: Creating stunning, interactive analytics charts for the dashboard.
- **[percent_indicator](https://pub.dev/packages/percent_indicator)**: Displaying circular and linear progress bars for daily calorie goals.
- **[device_preview](https://pub.dev/packages/device_preview)**: Ensuring the layout scaling looks perfect across all screen sizes and responsive devices.

### Device Integrations
- **[Image Picker](https://pub.dev/packages/image_picker)**: Allowing users to seamlessly access their camera and gallery for the Snap & Track AI feature.
- **[HTTP](https://pub.dev/packages/http)**: Handling reliable network requests to external AI Vision APIs for food recognition.

