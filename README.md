

# Reminder Calendar App

A cross-platform reminder and calendar app built with Flutter. Supports advanced features like recurring reminders, tags, search/filter, attachments, subtasks, markdown, location-based notifications, and theme switching (light/dark/system).

## Features


- Multi-platform: macOS, Windows, Linux, Android, iOS, Web
- Recurring reminders (daily, weekly, monthly, custom)
- Tagging and filtering
- Search reminders
- Mark as completed
- Custom notification sounds and snooze
- Attachments: images, files, voice notes
- Subtasks/checklists
- Rich text/Markdown in descriptions
- Location-based reminders (geofencing)
- Light, dark, and system theme modes (user selectable)

## Screenshots
<!-- Add screenshots here if available -->

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart 3.x
- For iOS: Xcode
- For Android: Android Studio or device/emulator
- For macOS: macOS 11+

### Getting Started

1. Clone this repository:
   ```sh
   git clone https://github.com/linhduongtuan/reminder_calendar_app
   cd reminder_calendar_app
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Generate Hive type adapters:
   ```sh
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:

   - macOS: `flutter run -d macos`
   - Windows: `flutter run -d windows`
   - Linux: `flutter run -d linux`
   - Android: `flutter run -d android`
   - iOS: `flutter run -d ios`
   - Web: `flutter run -d chrome`


### Build for release
- macOS: `flutter build macos`
- Windows: `flutter build windows`
- Linux: `flutter build linux`
- Android APK: `flutter build apk --release`
- Android AAB: `flutter build appbundle --release`
- iOS: `flutter build ios --release`
- Web: `flutter build web`

### Notes
- Notifications require permission on iOS/macOS. The app will prompt for this.
- Web notifications are not fully supported.
- To enable desktop/web, make sure to run `flutter create .` in the project root if not already done.

## Theme Switching
- Click the palette icon in the app bar to choose light, dark, or system mode.

## Data Storage
- Uses [Hive](https://docs.hivedb.dev/) for local storage. If you change data models, clear old Hive data to avoid migration issues.

## Customization
- Update app icons and metadata in `pubspec.yaml` and platform folders before release.

## Project Structure

- `lib/models/` - Data models, repository, theme provider
- `lib/screens/` - UI screens
- `lib/widgets/` - Reusable widgets
- `lib/notification_helper.dart` - Notification logic
- `pubspec.yaml` - Dependencies

## Dependencies
- [table_calendar](https://pub.dev/packages/table_calendar)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [hive](https://pub.dev/packages/hive)
- [hive_flutter](https://pub.dev/packages/hive_flutter)
- [provider](https://pub.dev/packages/provider)
- [path_provider](https://pub.dev/packages/path_provider)
- [rrule](https://pub.dev/packages/rrule)
- [flutter_markdown](https://pub.dev/packages/flutter_markdown)
- [permission_handler](https://pub.dev/packages/permission_handler)
- [geofence_service](https://pub.dev/packages/geofence_service)

## License

MIT License. See [LICENSE](LICENSE) for details.
