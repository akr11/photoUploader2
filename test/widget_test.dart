// This is a basic Flutter widget test for Photo Uploader app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:photo_uploader/main.dart';
import 'package:photo_uploader/services/upload_service.dart';
import 'package:photo_uploader/models/photo_upload.dart';

void main() {
  testWidgets('Photo Uploader smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts with the correct title
    expect(find.text('Завантаження фотографій'), findsOneWidget);

    // Verify that initial state shows no photos message
    expect(find.text('Немає вибраних фотографій'), findsOneWidget);

    // Verify that the main button is present
    expect(find.text('Вибрати фото'), findsOneWidget);
  });

  testWidgets('Upload Service initial state test', (WidgetTester tester) async {
    final uploadService = UploadService();

    // Test initial state
    expect(uploadService.photos.length, 0);
    expect(uploadService.isUploading, false);
    expect(uploadService.isAppActive, true);

    // Clean up
    uploadService.dispose();
  });

  testWidgets('Upload Service max photos limit test', (WidgetTester tester) async {
    final uploadService = UploadService();

    // Add 5 photos (max limit)
    final photoPaths = List.generate(5, (index) => 'test_photo_$index.jpg');
    uploadService.addPhotos(photoPaths);

    expect(uploadService.photos.length, 5);

    // Try to add more photos (should not exceed 5)
    final morePaths = ['extra_photo.jpg'];
    uploadService.addPhotos(morePaths);

    expect(uploadService.photos.length, 5); // Should still be 5

    // Clean up
    uploadService.dispose();
  });

  testWidgets('Upload Service photo removal test', (WidgetTester tester) async {
    final uploadService = UploadService();

    // Add some photos
    final photoPaths = ['photo1.jpg', 'photo2.jpg'];
    uploadService.addPhotos(photoPaths);

    expect(uploadService.photos.length, 2);

    // Remove one photo
    final photoToRemove = uploadService.photos.first;
    uploadService.removePhoto(photoToRemove.id);

    expect(uploadService.photos.length, 1);

    // Clear all photos
    uploadService.clearPhotos();
    expect(uploadService.photos.length, 0);

    // Clean up
    uploadService.dispose();
  });

  testWidgets('Upload Service app lifecycle test', (WidgetTester tester) async {
    final uploadService = UploadService();

    // Initially app should be active
    expect(uploadService.isAppActive, true);

    // Set app inactive
    uploadService.setAppActive(false);
    expect(uploadService.isAppActive, false);

    // Set app active again
    uploadService.setAppActive(true);
    expect(uploadService.isAppActive, true);

    // Clean up
    uploadService.dispose();
  });

  group('PhotoUpload model tests', () {
    test('PhotoUpload creation test', () {
      final photo = PhotoUpload(
        id: 'test_id',
        path: 'test_path.jpg',
      );

      expect(photo.id, 'test_id');
      expect(photo.path, 'test_path.jpg');
      expect(photo.status, UploadStatus.waiting);
      expect(photo.progress, 0.0);
      expect(photo.errorMessage, null);
    });

    test('PhotoUpload copyWith test', () {
      final photo = PhotoUpload(
        id: 'test_id',
        path: 'test_path.jpg',
      );

      final updatedPhoto = photo.copyWith(
        status: UploadStatus.uploading,
        progress: 0.5,
      );

      expect(updatedPhoto.id, 'test_id');
      expect(updatedPhoto.path, 'test_path.jpg');
      expect(updatedPhoto.status, UploadStatus.uploading);
      expect(updatedPhoto.progress, 0.5);
      expect(updatedPhoto.errorMessage, null);
    });

    test('PhotoUpload status transitions test', () {
      final photo = PhotoUpload(
        id: 'test_id',
        path: 'test_path.jpg',
      );

      // Test all status transitions
      final uploading = photo.copyWith(status: UploadStatus.uploading);
      expect(uploading.status, UploadStatus.uploading);

      final completed = uploading.copyWith(status: UploadStatus.completed);
      expect(completed.status, UploadStatus.completed);

      final error = uploading.copyWith(
        status: UploadStatus.error,
        errorMessage: 'Network error',
      );
      expect(error.status, UploadStatus.error);
      expect(error.errorMessage, 'Network error');
    });
  });
}