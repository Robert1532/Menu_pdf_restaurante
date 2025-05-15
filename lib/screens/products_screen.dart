import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_grid.dart';
import '../widgets/category_tabs.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> with SingleTickerProviderStateMixin {
  bool _isInit = true;
  bool _isLoading = false;
  String? _selectedCategory;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      
      final authProvider = Provider.of<AuthProvider>(context);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      if (authProvider.selectedEmpresaId != null) {
        print('Cargando productos para empresa ID: ${authProvider.selectedEmpresaId}');
        productProvider.fetchProducts(authProvider.selectedEmpresaId!).then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              if (productProvider.categories.isNotEmpty) {
                _selectedCategory = productProvider.categories.first;
              }
            });
          }
        }).catchError((error) {
          print('Error al cargar productos: $error');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      } else {
        print('No hay empresa seleccionada');
        setState(() {
          _isLoading = false;
        });
      }
      
      _isInit = false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categories = productProvider.categories;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (productProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar productos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              productProvider.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                Provider.of<ProductProvider>(context, listen: false)
                    .fetchProducts(Provider.of<AuthProvider>(context, listen: false).selectedEmpresaId!)
                    .then((_) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                });
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_food, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No hay productos disponibles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'No se encontraron productos para esta empresa',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (authProvider.selectedEmpresaId != null) {
                  setState(() {
                    _isLoading = true;
                  });
                  Provider.of<ProductProvider>(context, listen: false)
                      .fetchProducts(authProvider.selectedEmpresaId!)
                      .then((_) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  });
                }
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // Categorías
        CategoryTabs(
          categories: categories,
          selectedCategory: _selectedCategory,
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),
        
        // Productos
        if (_selectedCategory != null)
          Expanded(
            child: ProductGrid(
              products: productProvider.getProductsByCategory(_selectedCategory!),
              onProductSelected: (product) {
                // Mostrar detalles del producto
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (ctx) => Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nombre,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.descripcion,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Categoría: ${product.categoria}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  'Clasificador: ${product.clasificador}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Text(
                              '${product.precio.toStringAsFixed(2)} Bs.',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Chip(
                              label: Text(product.isDisponible ? 'Disponible' : 'No disponible'),
                              backgroundColor: product.isDisponible
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: product.isDisponible ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (product.isFavorito)
                              Chip(
                                label: const Text('Favorito'),
                                backgroundColor: Colors.amber.withOpacity(0.2),
                                labelStyle: TextStyle(color: Colors.amber.shade800),
                                avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
