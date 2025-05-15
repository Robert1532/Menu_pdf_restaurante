import 'product.dart';
import 'promotion.dart';

class Menu {
  String title;
  String? description;
  DateTime createdAt;
  String? backgroundImage;
  String? headerImage;
  String? footerImage;
  List<MenuCategory> categories;
  List<Promotion> promotions;
  
  Menu({
    required this.title,
    this.description,
    required this.createdAt,
    this.backgroundImage,
    this.headerImage,
    this.footerImage,
    required this.categories,
    required this.promotions,
  });
  
  factory Menu.empty() {
    return Menu(
      title: 'Nuevo Menú',
      createdAt: DateTime.now(),
      categories: [],
      promotions: [],
    );
  }
}

class MenuCategory {
  String name;
  String? description;
  String? image;
  List<Product> products;
  
  MenuCategory({
    required this.name,
    this.description,
    this.image,
    required this.products,
  });
}
