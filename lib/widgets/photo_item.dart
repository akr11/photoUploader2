import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo_upload.dart';

class PhotoItem extends StatelessWidget {
  final PhotoUpload photo;
  final VoidCallback? onRemove;

  const PhotoItem({
    super.key,
    required this.photo,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  child: Image.file(
                    File(photo.path),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (onRemove != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                _buildStatusOverlay(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _buildStatusIndicator(),
                if (photo.status == UploadStatus.uploading)
                  const SizedBox(height: 4),
                if (photo.status == UploadStatus.uploading)
                  LinearProgressIndicator(
                    value: photo.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOverlay() {
    Color overlayColor;
    IconData icon;

    switch (photo.status) {
      case UploadStatus.waiting:
        return const SizedBox.shrink();
      case UploadStatus.uploading:
        return Container(
          color: Colors.black54,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        );
      case UploadStatus.completed:
        overlayColor = Colors.green.withOpacity(0.8);
        icon = Icons.check_circle;
        break;
      case UploadStatus.error:
        overlayColor = Colors.red.withOpacity(0.8);
        icon = Icons.error;
        break;
    }

    return Container(
      color: overlayColor,
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    String statusText;
    Color statusColor;

    switch (photo.status) {
      case UploadStatus.waiting:
        statusText = 'В очікуванні';
        statusColor = Colors.orange;
        break;
      case UploadStatus.uploading:
        statusText = 'Завантажується ${(photo.progress * 100).toInt()}%';
        statusColor = Colors.blue;
        break;
      case UploadStatus.completed:
        statusText = 'Завантажено';
        statusColor = Colors.green;
        break;
      case UploadStatus.error:
        statusText = 'Помилка';
        statusColor = Colors.red;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 12,
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}