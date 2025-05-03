class PremiumizeAccountInfo {
  final String status;
  final String customerId;
  final int premiumUntil;
  final int limitUsed;
  final int spaceUsed;

  PremiumizeAccountInfo({
    required this.status,
    required this.customerId,
    required this.premiumUntil,
    required this.limitUsed,
    required this.spaceUsed,
  });

  factory PremiumizeAccountInfo.fromJson(Map<String, dynamic> json) {
    return PremiumizeAccountInfo(
      status: json['status'] ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      premiumUntil: int.tryParse(json['premium_until']?.toString() ?? '0') ?? 0,
      limitUsed: int.tryParse(json['limit_used']?.toString() ?? '0') ?? 0,
      spaceUsed: int.tryParse(json['space_used']?.toString() ?? '0') ?? 0,
    );
  }

  String get formattedSpaceUsed => _formatBytes(spaceUsed);
  
  String get formattedPremiumUntil {
    if (premiumUntil == 0) return 'N/A';
    final date = DateTime.fromMillisecondsSinceEpoch(premiumUntil * 1000);
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    if (bytes < 1024 * 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(2)} TB';
  }
} 