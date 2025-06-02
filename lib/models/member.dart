import 'package:gym_management_app/models/payment_status.dart';

class Member {
  final String id;
  final String name;
  final String phoneNumber;
  final DateTime membershipStartDate;
  final DateTime membershipEndDate;
  final bool isActive;
  final PaymentStatus paymentStatus;
  final double totalAmount;
  final double paidAmount;

  Member({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.membershipStartDate,
    required this.membershipEndDate,
    required this.totalAmount,
    required this.paidAmount,
    this.isActive = true,
    PaymentStatus? paymentStatus,
  }) : paymentStatus = paymentStatus ?? _calculatePaymentStatus(totalAmount, paidAmount);

  static PaymentStatus _calculatePaymentStatus(double total, double paid) {
    if (paid >= total) return PaymentStatus.fullyPaid;
    if (paid > 0) return PaymentStatus.partiallyPaid;
    return PaymentStatus.unpaid;
  }

  double get remainingAmount => totalAmount - paidAmount;

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      membershipStartDate: DateTime.parse(json['membershipStartDate']),
      membershipEndDate: DateTime.parse(json['membershipEndDate']),
      isActive: json['isActive'] ?? true,
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0.0).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['paymentStatus'],
        orElse: () => PaymentStatus.unpaid,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'membershipStartDate': membershipStartDate.toIso8601String(),
      'membershipEndDate': membershipEndDate.toIso8601String(),
      'isActive': isActive,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'paymentStatus': paymentStatus.toString(),
    };
  }

  bool get isExpired => membershipEndDate.isBefore(DateTime.now());

  Member copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    DateTime? membershipStartDate,
    DateTime? membershipEndDate,
    bool? isActive,
    PaymentStatus? paymentStatus,
    double? totalAmount,
    double? paidAmount,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      membershipStartDate: membershipStartDate ?? this.membershipStartDate,
      membershipEndDate: membershipEndDate ?? this.membershipEndDate,
      isActive: isActive ?? this.isActive,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
} 