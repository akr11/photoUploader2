import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/photo_upload.dart';

class UploadService {
  static const String _uploadUrl = 'https://httpbin.org/post'; // Тестовий endpoint
  
  final StreamController<List<PhotoUpload>> _photosController =
      StreamController<List<PhotoUpload>>.broadcast();
  
  List<PhotoUpload> _photos = [];
  bool _isUploading = false;
  bool _isAppActive = true; // Флаг активності додатку
  
  Stream<List<PhotoUpload>> get photosStream => _photosController.stream;
  List<PhotoUpload> get photos => List.unmodifiable(_photos);
  bool get isUploading => _isUploading;
  bool get isAppActive => _isAppActive;

  // Методи для керування станом активності додатку
  void setAppActive(bool active) {
    _isAppActive = active;
    if (!active && _isUploading) {
      // Якщо додаток стає неактивним під час завантаження - зупиняємо процес
      _pauseUpload();
    }
  }

  void _pauseUpload() {
    _isUploading = false;
    // Встановлюємо статус "в очікуванні" для фото які завантажуються
    for (int i = 0; i < _photos.length; i++) {
      if (_photos[i].status == UploadStatus.uploading) {
        _photos[i] = _photos[i].copyWith(
          status: UploadStatus.waiting,
          progress: 0.0,
        );
      }
    }
    _notifyListeners();
  }

  void addPhotos(List<String> paths) {
    for (String path in paths) {
      if (_photos.length >= 5) break;
      
      final photo = PhotoUpload(
        id: DateTime.now().millisecondsSinceEpoch.toString() + 
             Random().nextInt(1000).toString(),
        path: path,
      );
      _photos.add(photo);
    }
    _notifyListeners();
  }

  void removePhoto(String id) {
    _photos.removeWhere((photo) => photo.id == id);
    _notifyListeners();
  }

  void clearPhotos() {
    _photos.clear();
    _notifyListeners();
  }

  Future<void> startUpload() async {
    if (_isUploading || !_isAppActive) return;
    
    _isUploading = true;
    _notifyListeners();

    for (int i = 0; i < _photos.length; i++) {
      // Перевіряємо чи додаток все ще активний
      if (!_isAppActive) {
        _pauseUpload();
        return;
      }

      PhotoUpload photo = _photos[i];
      
      // Пропускаємо вже завантажені фото
      if (photo.status == UploadStatus.completed) continue;
      
      // Оновлюємо статус на "завантажується"
      _photos[i] = photo.copyWith(
        status: UploadStatus.uploading,
        progress: 0.0,
        errorMessage: null,
      );
      _notifyListeners();

      try {
        await _uploadPhoto(_photos[i], i);
      } catch (e) {
        _photos[i] = _photos[i].copyWith(
          status: UploadStatus.error,
          errorMessage: e.toString(),
        );
        _notifyListeners();
      }
    }

    _isUploading = false;
    _notifyListeners();
  }

  Future<void> _uploadPhoto(PhotoUpload photo, int index) async {
    final file = File(photo.path);
    if (!file.existsSync()) {
      throw Exception('Файл не знайдено');
    }

    // Симулюємо завантаження з прогресом
    for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
      // Перевіряємо чи додаток активний перед кожним кроком
      if (!_isAppActive) {
        throw Exception('Завантаження припинено - додаток неактивний');
      }

      await Future.delayed(const Duration(milliseconds: 300));
      
      _photos[index] = _photos[index].copyWith(progress: progress);
      _notifyListeners();
      
      // Симулюємо помилку мережі (10% шанс)
      if (progress > 0.3 && Random().nextDouble() < 0.1) {
        throw Exception('Помилка мережі');
      }
    }

    // Фінальна перевірка перед реальним запитом
    if (!_isAppActive) {
      throw Exception('Завантаження припинено - додаток неактивний');
    }

    // Реальний запит на сервер (для демонстрації)
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        _photos[index] = _photos[index].copyWith(
          status: UploadStatus.completed,
          progress: 1.0,
        );
      } else {
        throw Exception('Помилка сервера: ${response.statusCode}');
      }
    } catch (e) {
      // Для демонстрації вважаємо завантаження успішним
      _photos[index] = _photos[index].copyWith(
        status: UploadStatus.completed,
        progress: 1.0,
      );
    }
    
    _notifyListeners();
  }

  void retryFailedUploads() {
    if (!_isAppActive) return; // Не дозволяємо повторне завантаження якщо додаток неактивний

    for (int i = 0; i < _photos.length; i++) {
      if (_photos[i].status == UploadStatus.error) {
        _photos[i] = _photos[i].copyWith(
          status: UploadStatus.waiting,
          progress: 0.0,
          errorMessage: null,
        );
      }
    }
    _notifyListeners();
    startUpload();
  }

  void _notifyListeners() {
    _photosController.add(List.from(_photos));
  }

  void dispose() {
    _photosController.close();
  }
}