import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';
import '../models/promotion.dart';

class PromotionEditor extends StatefulWidget {
  final Promotion promotion;
  final List<Product> availableProducts;
  final Function(Promotion) onSave;
  
  const PromotionEditor({
    Key? key,
    required this.promotion,
    required this.availableProducts,
    required this.onSave,
  }) : super(key: key);

  @override
  State<PromotionEditor> createState() => _PromotionEditorState();
}

class _PromotionEditorState extends State<PromotionEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _originalPriceController;
  late TextEditingController _promotionalPriceController;
  late DateTime _startDate;
  late DateTime _endDate;
  late List<PromotionItem> _items;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.promotion.title);
    _descriptionController = TextEditingController(text: widget.promotion.description ?? '');
    _originalPriceController = TextEditingController(text: widget.promotion.originalPrice.toString());
    _promotionalPriceController = TextEditingController(text: widget.promotion.promotionalPrice.toString());
    _startDate = widget.promotion.startDate;
    _endDate = widget.promotion.endDate;
    _items = List.from(widget.promotion.items);
    
    // Calcular precio original si es una nueva promoción
    if (widget.promotion.originalPrice == 0 && _items.isNotEmpty) {
      _calculateOriginalPrice();
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _promotionalPriceController.dispose();
    super.dispose();
  }
  
  void _calculateOriginalPrice() {
    double total = 0;
    for (var item in _items) {
      total += item.product.precio * item.quantity;
    }
    _originalPriceController.text = total.toString();
  }
  
  void _addProduct(Product product) {
    // Verificar si el producto ya está en la lista
    final existingIndex = _items.indexWhere((item) => item.product.productoId == product.productoId);
    
    if (existingIndex >= 0) {
      // Incrementar cantidad
      setState(() {
        _items[existingIndex].quantity++;
      });
    } else {
      // Agregar nuevo producto
      setState(() {
        _items.add(PromotionItem(product: product));
      });
    }
    
    _calculateOriginalPrice();
  }
  
  void _removeProduct(int index) {
    setState(() {
      _items.removeAt(index);
    });
    
    _calculateOriginalPrice();
  }
  
  void _updateQuantity(int index, int quantity) {
    if (quantity < 1) return;
    
    setState(() {
      _items[index].quantity = quantity;
    });
    
    _calculateOriginalPrice();
  }
  
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: isStartDate ? DateTime.now() : _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Asegurar que la fecha de fin sea posterior a la de inicio
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Text(
                'Editar Promoción',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Formulario
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título de la promoción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              // Productos
              Text(
                'Productos en la promoción',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              if (_items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'No hay productos en esta promoción',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (ctx, index) {
                    final item = _items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            // Cantidad
                            Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16),
                                    onPressed: () => _updateQuantity(index, item.quantity - 1),
                                  ),
                                  Text(
                                    item.quantity.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: () => _updateQuantity(index, item.quantity + 1),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Información del producto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.nombre,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${item.product.precio.toStringAsFixed(2)} Bs. c/u',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Eliminar
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeProduct(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              
              const SizedBox(height: 16),
              
              // Botón para agregar productos
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (ctx) => ProductSelector(
                        availableProducts: widget.availableProducts,
                        onProductSelected: _addProduct,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Producto'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Precios
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _originalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio Original',
                        border: OutlineInputBorder(),
                        prefixText: 'Bs. ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _promotionalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio Promocional',
                        border: OutlineInputBorder(),
                        prefixText: 'Bs. ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Fechas
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de inicio',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_startDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de fin',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_endDate),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final promotion = Promotion(
                          title: _titleController.text,
                          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                          items: _items,
                          originalPrice: double.parse(_originalPriceController.text),
                          promotionalPrice: double.parse(_promotionalPriceController.text),
                          startDate: _startDate,
                          endDate: _endDate,
                        );
                        
                        widget.onSave(promotion);
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductSelector extends StatefulWidget {
  final List<Product> availableProducts;
  final Function(Product) onProductSelected;
  
  const ProductSelector({
    Key? key,
    required this.availableProducts,
    required this.onProductSelected,
  }) : super(key: key);

  @override
  State<ProductSelector> createState() => _ProductSelectorState();
}

class _ProductSelectorState extends State<ProductSelector> {
  String _searchQuery = '';
  String? _selectedCategory;
  
  List<String> get _categories {
    final categories = widget.availableProducts.map((p) => p.categoria).toSet().toList();
    categories.sort();
    return categories;
  }
  
  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty && _selectedCategory == null) {
      return widget.availableProducts;
    }
    
    return widget.availableProducts.where((product) {
      final matchesSearch = _searchQuery.isEmpty || 
          product.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.descripcion.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == null || 
          product.categoria == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seleccionar Productos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Búsqueda
          TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar productos',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Filtro por categoría
          DropdownButtonFormField<String?>(
            decoration: const InputDecoration(
              labelText: 'Filtrar por categoría',
              border: OutlineInputBorder(),
            ),
            value: _selectedCategory,
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Todas las categorías'),
              ),
              ..._categories.map((category) => DropdownMenuItem<String?>(
                value: category,
                child: Text(category),
              )).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Lista de productos
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Text(
                      'No se encontraron productos',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (ctx, index) {
                      final product = _filteredProducts[index];
                      return ListTile(
                        title: Text(product.nombre),
                        subtitle: Text(
                          '${product.precio.toStringAsFixed(2)} Bs. - ${product.clasificador}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            widget.onProductSelected(product);
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
