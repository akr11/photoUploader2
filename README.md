# Photo Uploader - Flutter App

A Flutter application prototype for uploading photos from gallery to server with queue management, progress tracking, and error recovery.

## Features

✅ **Photo Selection**: Select up to 5 photos from gallery  
✅ **Upload Queue**: Photos upload one by one (sequential)  
✅ **Progress Tracking**: Real-time upload progress display  
✅ **Status Management**: Track each photo's status (pending, uploading, uploaded, error)  
✅ **Error Recovery**: Retry failed uploads  
✅ **Network Interruption Handling**: Failed uploads remain in queue  
✅ **Foreground Only**: Upload works only while app is active  

## Screenshots

The app displays:
- Photo selection interface with gallery picker
- Upload queue with individual photo status
- Progress bars during upload
- Retry functionality for failed uploads
- Status indicator showing "Photo X of Y uploading"

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/akr11/photoUploader2
   cd flutter-photo-uploader
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Android Permissions

The app requires camera and storage permissions. Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select images for upload</string>
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos</string>
```

## Technical Implementation

### Architecture Decisions

**State Management**: Used built-in `setState()` for simplicity and prototype requirements. For production, consider Provider, BLoC, or Riverpod.

**Photo Status Tracking**: Implemented custom enum `PhotoStatus` with four states:
- `pending`: Ready to upload
- `uploading`: Currently being uploaded
- `uploaded`: Successfully uploaded
- `error`: Failed to upload

**Upload Queue**: Sequential processing using a simple for-loop to ensure one-by-one uploads as requested.

**Progress Tracking**: Simulated progress updates during upload (in production, use actual HTTP stream progress).

**Error Recovery**: Failed photos retain error state and can be retried individually or in batch.

### Key Components

- **PhotoItem Model**: Represents each photo with status, progress, and error information
- **ImagePicker**: For gallery selection (supports multi-selection)
- **HTTP Client**: For multipart file uploads
- **Progress Indicators**: Linear progress bars and status icons

### Dependencies Used

- `image_picker: ^1.0.4` - Gallery/camera photo selection
- `http: ^1.1.0` - HTTP requests for file upload
- `path: ^1.8.3` - File path utilities

**Minimal Dependencies**: Only essential packages used, no unnecessary bloat.

## Usage Instructions

1. **Select Photos**: Tap "Select Photos" to choose up to 5 images from gallery
2. **Upload**: Press "Upload" to start sequential upload process
3. **Monitor Progress**: Watch real-time progress and status updates
4. **Handle Errors**: If uploads fail, use "Retry" button to upload only failed photos
5. **Remove Photos**: Use delete button to remove photos from queue

## Server Configuration

Currently configured to use `https://httpbin.org/post` as a mock endpoint for testing. 

To use your own server:
1. Replace `uploadUrl` constant in `main.dart`
2. Ensure your server accepts multipart/form-data POST requests
3. The photo file is sent with field name "photo"

## Code Structure

```
lib/
├── main.dart           # Main app with all functionality
```

The entire app is contained in a single file for prototype simplicity while maintaining clean code structure with:

- Separate widgets for different UI sections
- Clear state management
- Error handling
- Comprehensive comments

## Testing

The app has been tested with:
- Photo selection (single and multiple)
- Upload progress simulation
- Network interruption scenarios
- Error recovery workflows
- UI state transitions

## Future Enhancements

For production deployment, consider:
- Background upload capability
- Upload resumption for large files
- Image compression before upload
- Cloud storage integration
- User authentication
- Upload history persistence
- Better error messaging
- Network connectivity checking

## License

This project is created as a prototype for demonstration purposes.

