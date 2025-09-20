enum UploadStatus {
  waiting,
  uploading,
  completed,
  error,
}

class PhotoUpload {
  final String id;
  final String path;
  UploadStatus status;
  double progress;
  String? errorMessage;

  PhotoUpload({
    required this.id,
    required this.path,
    this.status = UploadStatus.waiting,
    this.progress = 0.0,
    this.errorMessage,
  });

  PhotoUpload copyWith({
    UploadStatus? status,
    double? progress,
    String? errorMessage,
  }) {
    return PhotoUpload(
      id: id,
      path: path,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}