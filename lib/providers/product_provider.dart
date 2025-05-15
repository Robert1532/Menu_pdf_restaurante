import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  final String? _token;
  
  ProductProvider(this._token, this._products);
  
  List<Product> get products => [..._products];
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<String> get categories {
    final categories = _products.map((product) => product.categoria).toSet().toList();
    categories.sort();
    return categories;
  }
  
  List<String> getClassificadoresByCategory(String category) {
    final classificadores = _products
        .where((product) => product.categoria == category)
        .map((product) => product.clasificador)
        .toSet()
        .toList();
    classificadores.sort();
    return classificadores;
  }
  
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.categoria == category).toList();
  }
  
  List<Product> getProductsByClassificador(String category, String clasificador) {
    return _products.where(
      (product) => product.categoria == category && product.clasificador == clasificador
    ).toList();
  }
  
  Future<void> fetchProducts(int empresaId) async {
    if (_token == null) {
      _error = 'No hay sesión activa';
      notifyListeners();
      return;
    }
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      print('Obteniendo productos para empresa ID: $empresaId');
      final apiService = ApiService(token: _token);
      final products = await apiService.getProducts(empresaId);
      
      print('Productos obtenidos: ${products.length}');
      _products = products;
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      print('Error al obtener productos: $error');
      _isLoading = false;
      _error = error.toString();
      notifyListeners();
    }
  }
  
  void toggleProductSelection(int productId) {
    final productIndex = _products.indexWhere((product) => product.productoId == productId);
    if (productIndex >= 0) {
      _products[productIndex].isSelected = !_products[productIndex].isSelected;
      notifyListeners();
    }
  }
  
  void updateProductQuantity(int productId, int quantity) {
    final productIndex = _products.indexWhere((product) => product.productoId == productId);
    if (productIndex >= 0) {
      _products[productIndex].quantity = quantity;
      notifyListeners();
    }
  }
  
  List<Product> getSelectedProducts() {
    return _products.where((product) => product.isSelected).toList();
  }
  
  void clearSelections() {
    for (var product in _products) {
      product.isSelected = false;
      product.quantity = 1;
    }
    notifyListeners();
  }
}
