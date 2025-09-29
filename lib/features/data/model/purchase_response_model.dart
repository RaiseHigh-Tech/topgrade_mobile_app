class PurchaseResponseModel {
  final bool success;
  final String message;
  final PricingModel pricing;
  final PurchaseModel purchase;

  PurchaseResponseModel({
    required this.success,
    required this.message,
    required this.pricing,
    required this.purchase,
  });

  factory PurchaseResponseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      pricing: PricingModel.fromJson(json['pricing'] ?? {}),
      purchase: PurchaseModel.fromJson(json['purchase'] ?? {}),
    );
  }
}

class PricingModel {
  final double originalPrice;
  final double discountPercentage;
  final double discountedPrice;
  final double savings;

  PricingModel({
    required this.originalPrice,
    required this.discountPercentage,
    required this.discountedPrice,
    required this.savings,
  });

  factory PricingModel.fromJson(Map<String, dynamic> json) {
    return PricingModel(
      originalPrice: (json['original_price'] ?? 0.0).toDouble(),
      discountPercentage: (json['discount_percentage'] ?? 0.0).toDouble(),
      discountedPrice: (json['discounted_price'] ?? 0.0).toDouble(),
      savings: (json['savings'] ?? 0.0).toDouble(),
    );
  }
}

class PurchaseModel {
  final int id;
  final String programTitle;
  final String programCategory;
  final DateTime purchaseDate;
  final String status;
  final double amountPaid;
  final String transactionId;

  PurchaseModel({
    required this.id,
    required this.programTitle,
    required this.programCategory,
    required this.purchaseDate,
    required this.status,
    required this.amountPaid,
    required this.transactionId,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'] ?? 0,
      programTitle: json['program_title'] ?? '',
      programCategory: json['program_category'] ?? '',
      purchaseDate: DateTime.tryParse(json['purchase_date'] ?? '') ?? DateTime.now(),
      amountPaid: (json['amount_paid'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      transactionId: json['transaction_id'] ?? '',
    );
  }
}