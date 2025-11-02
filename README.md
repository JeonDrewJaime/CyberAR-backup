# Flutter Unity Widget

A Flutter Unity 3D widget for embedding Unity game scenes in Flutter applications. This library supports Unity as a Library (UaaL) for seamless integration.

## How to Run the Flutter App

### Prerequisites
- Flutter SDK (>=3.16.0)
- Dart SDK (>=3.2.0)
- Unity 2022.3.62f1 (for Unity project development)
- Android Studio / Xcode (for mobile development)

### Running the Example App

1. **Navigate to the example directory:**
   ```bash
   cd example/
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the Flutter app:**
   ```bash
   # For Android
   flutter run
   
   # For iOS (macOS only)
   flutter run -d ios
   
   # For web
   flutter run -d web
   ```

4. **The app will launch with Unity content embedded** - you'll see the Flutter UI with Unity 3D scenes integrated.

### Alternative: Run with specific device
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Project Structure

- `lib/` - Flutter Unity Widget plugin source code
- `example/` - Example Flutter application demonstrating the plugin
  - `example/unity/DemoApp/` - Unity project with demo scenes
  - `example/lib/` - Flutter app source code
- `android/` - Android platform-specific code
- `ios/` - iOS platform-specific code
- `unitypackages/` - Unity package files for different versions

## Unity Project

The Unity project is located in `example/unity/DemoApp/` and contains:
- `Assets/` - Unity assets, scripts, and scenes
- `ProjectSettings/` - Unity project configuration
- `Packages/` - Unity package dependencies
- `Library/` - Unity's internal cache (included for consistency)

### Unity Setup
1. Open `example/unity/DemoApp/` in Unity 2022.3.62f1
2. The project will automatically import all necessary packages
3. The Unity project is configured to work with the Flutter Unity Widget plugin

## Development

### Plugin Development
- The main plugin code is in `lib/`
- Platform-specific implementations are in `android/` and `ios/`
- Example usage is in `example/lib/`

### Unity Development
- Unity project is in `example/unity/DemoApp/`
- All essential Unity files are tracked in git for consistency
- Build artifacts are excluded from version control

## Troubleshooting

### Flutter App Issues
- Ensure Flutter SDK is properly installed and configured
- Run `flutter doctor` to check for issues
- Make sure you have the correct platform dependencies (Android SDK, Xcode)

### Unity Integration Issues
- Ensure Unity 2022.3.62f1 is installed
- Check that the Unity project opens without errors
- Verify that all packages are properly imported in Unity

### Build Issues
- Clean and rebuild: `flutter clean && flutter pub get`
- For Android: Check that Android SDK and NDK are properly configured
- For iOS: Ensure Xcode and iOS development tools are installed

## Notes

- The Unity `Library/` folder is included in version control for consistency across different development environments
- Build artifacts (`Builds/`, `Temp/`, `Logs/`) are excluded from version control
- This project supports Android, iOS, and Web platforms
