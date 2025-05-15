import 'product.dart';

class Promotion {
  String title;
  String? description;
  List<PromotionItem> items;
  double originalPrice;
  double promotionalPrice;
  DateTime startDate;
  DateTime endDate;
  
  Promotion({
    required this.title,
    this.description,
    required this.items,
    required this.originalPrice,
    required this.promotionalPrice,
    required this.startDate,
    required this.endDate,
  });
  
  factory Promotion.empty() {
    return Promotion(
      title: 'Nueva Promoción',
      items: [],
      originalPrice: 0,
      promotionalPrice: 0,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
    );
  }
}

class PromotionItem {
  final Product product;
  int quantity;
  
  PromotionItem({
    required this.product,
    this.quantity = 1,
  });
}
