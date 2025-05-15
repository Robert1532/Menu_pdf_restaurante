import 'package:flutter/foundation.dart';

import '../models/menu.dart';
import '../models/product.dart';
import '../models/promotion.dart';

class MenuProvider with ChangeNotifier {
  Menu? _currentMenu;
  final List<Product> _availableProducts;
  
  MenuProvider(this._availableProducts) {
    _currentMenu = Menu.empty();
    _initializeCategories();
  }
  
  Menu? get currentMenu => _currentMenu;
  
  void _initializeCategories() {
    if (_currentMenu == null || _availableProducts.isEmpty) return;
    
    // Agrupar productos por categoría
    final Map<String, List<Product>> productsByCategory = {};
    
    for (final product in _availableProducts) {
      if (!productsByCategory.containsKey(product.categoria)) {
        productsByCategory[product.categoria] = [];
      }
      productsByCategory[product.categoria]!.add(product);
    }
    
    // Crear categorías para el menú
    final List<MenuCategory> categories = [];
    
    productsByCategory.forEach((categoryName, products) {
      categories.add(
        MenuCategory(
          name: categoryName,
          products: [...products],
        ),
      );
    });
    
    // Ordenar categorías alfabéticamente
    categories.sort((a, b) => a.name.compareTo(b.name));
    
    _currentMenu!.categories = categories;
    notifyListeners();
  }
  
  void updateMenuTitle(String title) {
    if (_currentMenu == null) return;
    _currentMenu!.title = title;
    notifyListeners();
  }
  
  void updateMenuDescription(String description) {
    if (_currentMenu == null) return;
    _currentMenu!.description = description;
    notifyListeners();
  }
  
  void updateMenuBackground(String imagePath) {
    if (_currentMenu == null) return;
    _currentMenu!.backgroundImage = imagePath;
    notifyListeners();
  }
  
  void updateMenuHeader(String imagePath) {
    if (_currentMenu == null) return;
    _currentMenu!.headerImage = imagePath;
    notifyListeners();
  }
  
  void updateMenuFooter(String imagePath) {
    if (_currentMenu == null) return;
    _currentMenu!.footerImage = imagePath;
    notifyListeners();
  }
  
  void updateCategoryImage(String categoryName, String imagePath) {
    if (_currentMenu == null) return;
    
    final categoryIndex = _currentMenu!.categories.indexWhere(
      (category) => category.name == categoryName
    );
    
    if (categoryIndex >= 0) {
      _currentMenu!.categories[categoryIndex].image = imagePath;
      notifyListeners();
    }
  }
  
  void updateCategoryDescription(String categoryName, String description) {
    if (_currentMenu == null) return;
    
    final categoryIndex = _currentMenu!.categories.indexWhere(
      (category) => category.name == categoryName
    );
    
    if (categoryIndex >= 0) {
      _currentMenu!.categories[categoryIndex].description = description;
      notifyListeners();
    }
  }
  
  void toggleProductInMenu(String categoryName, int productId) {
    if (_currentMenu == null) return;
    
    final categoryIndex = _currentMenu!.categories.indexWhere(
      (category) => category.name == categoryName
    );
    
    if (categoryIndex >= 0) {
      final category = _currentMenu!.categories[categoryIndex];
      final productIndex = category.products.indexWhere(
        (product) => product.productoId == productId
      );
      
      if (productIndex >= 0) {
        // Eliminar producto
        category.products.removeAt(productIndex);
      } else {
        // Agregar producto
        final product = _availableProducts.firstWhere(
          (product) => product.productoId == productId
        );
        category.products.add(product);
      }
      
      notifyListeners();
    }
  }
  
  void addPromotion(Promotion promotion) {
    if (_currentMenu == null) return;
    _currentMenu!.promotions.add(promotion);
    notifyListeners();
  }
  
  void updatePromotion(int index, Promotion promotion) {
    if (_currentMenu == null || index < 0 || index >= _currentMenu!.promotions.length) return;
    _currentMenu!.promotions[index] = promotion;
    notifyListeners();
  }
  
  void removePromotion(int index) {
    if (_currentMenu == null || index < 0 || index >= _currentMenu!.promotions.length) return;
    _currentMenu!.promotions.removeAt(index);
    notifyListeners();
  }
  
  void createNewMenu() {
    _currentMenu = Menu.empty();
    _initializeCategories();
  }
}
