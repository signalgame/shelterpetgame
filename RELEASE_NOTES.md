# 🚀 Release Preparation Notes

This document contains instructions for finalizing the release build of Pet Shelter Rush.

## 1. 🎨 App Icons

We have configured `flutter_launcher_icons` in `pubspec.yaml` to generate app icons from `assets/images/ui/logo.png`.

**Action Required:**
Run the following commands in your terminal to generate the icons:

```bash
flutter pub get
dart run flutter_launcher_icons
```

## 2. 📱 Launch Screen

- **Android**: Background color updated to `#FFF9E6` in `android/app/src/main/res/drawable/launch_background.xml`.
- **iOS**: Background color updated to RGB(1.0, 0.976, 0.902) in `ios/Runner/Base.lproj/LaunchScreen.storyboard`.

## 3. 🔊 Audio & Polishing

- **Sound Checks**: Verified that all buttons (Privacy Policy, Level Select, Pause, Game Over, etc.) have sound effects attached.
- **Timer**: Updated timer logic to use `ceil()` for countdowns (Level Mode) so it doesn't show "00:00" prematurely, and `floor()` for count-ups (Endless Mode).

## 4. 📦 Building for Release

### Android

To build a release APK:

```bash
flutter build apk --release
```

To build an App Bundle (recommended for Google Play):

```bash
flutter build appbundle --release
```

*Note: The current build configuration uses the default debug signing key. To publish to the Play Store, you must configure a release signing key in `android/key.properties` and update `android/app/build.gradle.kts`.*

### iOS

To build for iOS (requires Xcode):

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and upload to the App Store.

## 5. ✅ Final Checklist

Before publishing, please manually verify:
- [ ] **Level Progression**: Complete Level 1 and ensure Level 2 unlocks.
- [ ] **Endless Mode**: Complete all 12 levels and ensure Endless Mode unlocks.
- [ ] **Data Persistence**: Play a level, close the app completely, reopen it, and check if stats/progress are saved.
- [ ] **Sound Toggle**: Turn sound off in Main Menu, restart app, ensure sound remains off.
- [ ] **Performance**: Test on a physical device to ensure 60fps gameplay.

