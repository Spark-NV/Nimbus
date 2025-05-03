class PremiumizeTransfer {
  final String id;
  final String name;
  final String status;
  final double progress;
  final String? message;
  final String? folderId;
  final String? fileId;
  final String? otherCloudId;
  final String? src;

  PremiumizeTransfer({
    required this.id,
    required this.name,
    required this.status,
    required this.progress,
    this.message,
    this.folderId,
    this.fileId,
    this.otherCloudId,
    this.src,
  });

  factory PremiumizeTransfer.fromJson(Map<String, dynamic> json) {
    return PremiumizeTransfer(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num).toDouble() * 100,
      message: json['message'] as String?,
      folderId: json['folder_id'] as String?,
      fileId: json['file_id'] as String?,
      otherCloudId: json['other_cloud_id'] as String?,
      src: json['src'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'progress': progress / 100,
      if (message != null) 'message': message,
      if (folderId != null) 'folder_id': folderId,
      if (fileId != null) 'file_id': fileId,
      if (otherCloudId != null) 'other_cloud_id': otherCloudId,
      if (src != null) 'src': src,
    };
  }

  bool get isFinished => status == 'finished';
  bool get isError => status == 'error';
  bool get isRunning => status == 'running';
  
  String get formattedSize {
    final message = this.message ?? '';
    final sizeMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:MB|GB|TB)\s+of\s+(\d+(?:\.\d+)?)\s*(?:MB|GB|TB)').firstMatch(message);
    if (sizeMatch != null) {
      final currentSize = sizeMatch.group(1) ?? '0';
      final totalSize = sizeMatch.group(2) ?? '0';
      final unit = sizeMatch.group(0)?.contains('GB') == true ? 'GB' : 
                   sizeMatch.group(0)?.contains('TB') == true ? 'TB' : 'MB';
      return '$currentSize $unit of $totalSize $unit';
    }
    return 'Unknown size';
  }
  
  String get currentSize {
    final message = this.message ?? '';
    final sizeMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:MB|GB|TB)\s+of').firstMatch(message);
    if (sizeMatch != null) {
      return sizeMatch.group(1) ?? '0';
    }
    return '0';
  }
  
  String get totalSize {
    final message = this.message ?? '';
    final sizeMatch = RegExp(r'of\s+(\d+(?:\.\d+)?)\s*(?:MB|GB|TB)').firstMatch(message);
    if (sizeMatch != null) {
      return sizeMatch.group(1) ?? '0';
    }
    return '0';
  }
  
  String get sizeUnit {
    final message = this.message ?? '';
    if (message.contains('TB')) return 'TB';
    if (message.contains('GB')) return 'GB';
    return 'MB';
  }
} 