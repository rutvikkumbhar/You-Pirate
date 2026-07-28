class DownloadHistory {
  final int? id;
  final String title;
  final String thumbnail;
  final String sourceUrl;
  final String platform;
  final String mediaType;
  final String formatId;
  final String quality;
  final String extension;
  final String filePath;
  final String fileSize;
  final String duration;
  final String downloadDate;
  final int status;

  const DownloadHistory({
    this.id,
    required this.title,
    required this.thumbnail,
    required this.sourceUrl,
    required this.platform,
    required this.mediaType,
    required this.formatId,
    required this.quality,
    required this.extension,
    required this.filePath,
    required this.fileSize,
    required this.duration,
    required this.downloadDate,
    this.status = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'sourceUrl': sourceUrl,
      'platform': platform,
      'mediaType': mediaType,
      'formatId': formatId,
      'quality': quality,
      'extension': extension,
      'filePath': filePath,
      'fileSize': fileSize,
      'duration': duration,
      'downloadDate': downloadDate,
      'status': status,
    };
  }
}