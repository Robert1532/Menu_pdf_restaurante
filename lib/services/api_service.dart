import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/product.dart';
import '../models/empresa.dart';

class ApiService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
  final String? token;
  
  ApiService({this.token});
  
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  
  Future<List<Product>> getProducts(int empresaId) async {
    try {
      print('Solicitando productos de la API para empresa ID: $empresaId');
      print('URL: $baseUrl/api/erpproductos');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/erpproductos'),
        headers: headers,
      );
      
      print('Respuesta de API productos: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        print('Total de productos recibidos: ${productsJson.length}');
        
        final List<Product> allProducts = [];
        for (var json in productsJson) {
          try {
            allProducts.add(Product.fromJson(json));
          } catch (e) {
            print('Error al procesar producto: $e');
          }
        }
        
        print('Productos procesados correctamente: ${allProducts.length}');
        
        // Filtrar productos por empresa y disponibilidad
        final filteredProducts = allProducts.where((product) => 
          product.empresaId == empresaId && 
          product.isDisponible && 
          !product.isDescontinuado
        ).toList();
        
        print('Productos filtrados para empresa $empresaId: ${filteredProducts.length}');
        
        return filteredProducts;
      } else {
        print('Error HTTP al obtener productos: ${response.statusCode}');
        throw Exception('Error al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener productos: $e');
      throw Exception('Error al obtener productos: $e');
    }
  }
  
  Future<Empresa> getEmpresa(int empresaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/erpempresas/$empresaId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final empresaJson = json.decode(response.body);
        return Empresa.fromJson(empresaJson);
      } else {
        throw Exception('Error al obtener empresa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener empresa: $e');
    }
  }
}
