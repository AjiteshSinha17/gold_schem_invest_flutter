class LocalPayment {
  final String userId;
  final String schemeId;
  final String paymentId;
  final String amount;
  final int actionType;
  final String gateway;
  final String? passbookName;
  final String? passbookAddress;
  final String? passbookId;
  final String? uniqId;
  final DateTime timestamp;
  final String status; // 'pending', 'completed', 'failed'

  LocalPayment({
    required this.userId,
    required this.schemeId,
    required this.paymentId,
    required this.amount,
    required this.actionType,
    required this.gateway,
    this.passbookName,
    this.passbookAddress,
    this.passbookId,
    this.uniqId,
    DateTime? timestamp,
    this.status = 'pending',
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'schemeId': schemeId,
    'paymentId': paymentId,
    'amount': amount,
    'actionType': actionType,
    'gateway': gateway,
    'passbookName': passbookName,
    'passbookAddress': passbookAddress,
    'passbookId': passbookId,
    'uniqId': uniqId,
    'timestamp': timestamp.toIso8601String(),
    'status': status,
  };

  factory LocalPayment.fromJson(Map<String, dynamic> json) {
    try {
      // Parse timestamp with fallback to current time if invalid
      DateTime parsedTimestamp;
      try {
        parsedTimestamp = DateTime.parse(json['timestamp'] as String);
      } catch (e) {
        parsedTimestamp = DateTime.now();
      }

      return LocalPayment(
        userId: json['userId']?.toString() ?? '',
        schemeId: json['schemeId']?.toString() ?? '',
        paymentId: json['paymentId']?.toString() ?? '',
        amount: json['amount']?.toString() ?? '0',
        actionType: (json['actionType'] as int?) ?? 0,
        gateway: json['gateway']?.toString() ?? '',
        passbookName: json['passbookName']?.toString(),
        passbookAddress: json['passbookAddress']?.toString(),
        passbookId: json['passbookId']?.toString(),
        uniqId: json['uniqId']?.toString(),
        timestamp: parsedTimestamp,
        status: json['status']?.toString().toLowerCase() ?? 'pending',
      );
    } catch (e) {
    
      rethrow;
    }
  }
}