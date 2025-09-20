import 'package:flutter/material.dart';
import '../models/photo_upload.dart';
import 'photo_item.dart';

class PhotoGrid extends StatelessWidget {
  final List<PhotoUpload> photos;
  final Function(String) onRemovePhoto;

  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Немає вибраних фотографій',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return PhotoItem(
          photo: photo,
          onRemove: photo.status == UploadStatus.uploading
              ? null
              : () => onRemovePhoto(photo.id),
        );
      },
    );
  }
}