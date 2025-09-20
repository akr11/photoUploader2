import 'package:flutter/material.dart';
import '../models/photo_upload.dart';

class UploadProgress extends StatelessWidget {
  final List<PhotoUpload> photos;

  const UploadProgress({
    super.key,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    final uploadingPhoto = photos.firstWhere(
      (photo) => photo.status == UploadStatus.uploading,
      orElse: () => PhotoUpload(id: '', path: ''),
    );

    if (uploadingPhoto.id.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentIndex = photos.indexOf(uploadingPhoto) + 1;
    final totalPhotos = photos.length;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Фото $currentIndex із $totalPhotos завантажується',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: uploadingPhoto.progress,
            backgroundColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}