# 🥗 NutriScan

**NutriScan** is an AI-powered calorie tracking application built with Flutter. It helps users effortlessly log their meals, track daily caloric intake, and analyze their nutritional habits over time—especially focusing on Indian cuisine.

---

## ✨ Key Features

- 📸 **Snap & Track**: Simply take a photo of your meal and let AI instantly analyze the food and estimate its calorie content.
- 🍛 **Indian Food Database**: Built-in support for a vast database of Indian food items (e.g., Roti, Dal, Paneer, Biryani, and 35+ other common dishes).
- 📊 **Smart Analytics**: Interactive charts, daily streaks, and a 30-day history view to keep you motivated and on track.
- 🔐 **Seamless Authentication**: Secure and frictionless Google Sign-In powered by Firebase Authentication.
- 🌙 **Modern UI/UX**: Premium design aesthetics featuring beautiful typography, smooth animations, and a polished user experience.

---

## 🛠️ Technology Stack

NutriScan is built using modern and robust technologies to ensure performance, scalability, and a great developer experience.

### Framework & Core
- **[Flutter](https://flutter.dev/)**: Cross-platform UI toolkit for natively compiled applications (iOS, Android, Web).
- **Dart**: Programming language used by Flutter.

### Backend & Authentication
- **[Firebase Authentication](https://firebase.google.com/docs/auth)**: Secure identity management.
- **Google Sign-In**: Easy one-tap login for users across platforms (integrated natively on mobile and via Firebase pop-up on Web).

### State Management & Architecture
- **[Provider](https://pub.dev/packages/provider)**: Simple, flexible, and scalable state management solution for Flutter.

### Storage & Data
- **[Shared Preferences](https://pub.dev/packages/shared_preferences)**: Used for persisting user session and local lightweight data between app launches.

### User Interface & Design
- **[Google Fonts](https://pub.dev/packages/google_fonts)**: Utilizing **Outfit** for beautiful headers and **Inter** for highly readable body text.
- **[fl_chart](https://pub.dev/packages/fl_chart)**: Creating stunning, interactive analytics charts for the dashboard.
- **[percent_indicator](https://pub.dev/packages/percent_indicator)**: Displaying circular and linear progress bars for daily calorie goals.
- **[device_preview](https://pub.dev/packages/device_preview)**: Ensuring the app looks perfect across all screen sizes and devices.

### Device Integrations
- **[Image Picker](https://pub.dev/packages/image_picker)**: Allowing users to access their camera and gallery for the Snap & Track AI feature.
- **[HTTP](https://pub.dev/packages/http)**: Handling network requests to external AI APIs for food recognition.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (`>=3.1.0`)
- Firebase project configured with Google Sign-In enabled.

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/nutriscan.git
   cd nutriscan
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```
   *(For web testing, you can use `flutter run -d chrome`)*

---
*Built with ❤️ using Flutter.*
