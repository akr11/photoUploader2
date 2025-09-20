import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/photo_upload.dart';
import '../services/upload_service.dart';
import '../widgets/photo_grid.dart';
import '../widgets/upload_progress.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> with WidgetsBindingObserver {
  final UploadService _uploadService = UploadService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Додаємо observer для відстеження стану додатку
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uploadService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Відстежуємо стан активності додатку
    switch (state) {
      case AppLifecycleState.resumed:
        _uploadService.setAppActive(true);
        _showSnackBar('Додаток активний');
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _uploadService.setAppActive(false);
        _showSnackBar('Завантаження призупинено - додаток неактивний');
        break;
      case AppLifecycleState.hidden:
        _uploadService.setAppActive(false);
        break;
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      final currentCount = _uploadService.photos.length;
      final availableSlots = 5 - currentCount;
      
      if (availableSlots <= 0) {
        _showSnackBar('Максимум 5 фотографій');
        return;
      }
      
      final imagesToAdd = images.take(availableSlots).map((e) => e.path).toList();
      _uploadService.addPhotos(imagesToAdd);
      
      if (images.length > availableSlots) {
        _showSnackBar('Додано $availableSlots з ${images.length} фотографій (максимум 5)');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Завантаження фотографій'),
        elevation: 2,
      ),
      body: StreamBuilder<List<PhotoUpload>>(
        stream: _uploadService.photosStream,
        initialData: _uploadService.photos,
        builder: (context, snapshot) {
          final photos = snapshot.data ?? [];
          
          return Column(
            children: [
              UploadProgress(photos: photos),
              Expanded(
                child: PhotoGrid(
                  photos: photos,
                  onRemovePhoto: _uploadService.removePhoto,
                ),
              ),
              _buildBottomBar(photos),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(List<PhotoUpload> photos) {
    final hasPhotos = photos.isNotEmpty;
    final hasFailedUploads = photos.any((p) => p.status == UploadStatus.error);
    final isUploading = _uploadService.isUploading;
    final canAddMore = photos.length < 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (canAddMore) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isUploading ? null : _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(
                        hasPhotos 
                          ? 'Додати фото (${photos.length}/5)'
                          : 'Вибрати фото',
                      ),
                    ),
                  ),
                  if (hasPhotos) const SizedBox(width: 8),
                ],
                if (hasPhotos && !isUploading)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _uploadService.clearPhotos();
                        _showSnackBar('Всі фото видалено');
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Очистити'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            if (hasPhotos) const SizedBox(height: 8),
            if (hasPhotos)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (isUploading || !_uploadService.isAppActive) ? null : () {
                        _uploadService.startUpload();
                        _showSnackBar('Розпочато завантаження');
                      },
                      icon: Icon(isUploading 
                        ? Icons.hourglass_empty 
                        : Icons.cloud_upload
                      ),
                      label: Text(isUploading 
                        ? 'Завантажується...' 
                        : 'Завантажити'
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  if (hasFailedUploads && !isUploading) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: !_uploadService.isAppActive ? null : () {
                          _uploadService.retryFailedUploads();
                          _showSnackBar('Повторне завантаження розпочато');
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Повторити'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}