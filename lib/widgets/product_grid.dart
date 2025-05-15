import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductSelected;
  
  const ProductGrid({
    Key? key,
    required this.products,
    required this.onProductSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Text('No hay productos en esta categoría'),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, index) {
        final product = products[index];
        
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            onTap: () => onProductSelected(product),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen o placeholder
                Container(
                  height: 120,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Clasificador
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.clasificador,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Nombre
                        Text(
                          product.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Descripción
                        Expanded(
                          child: Text(
                            product.descripcion,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Precio
                        Text(
                          '${product.precio.toStringAsFixed(2)} Bs.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
