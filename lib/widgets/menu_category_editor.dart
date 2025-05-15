import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/menu.dart';
import '../models/product.dart';

class MenuCategoryEditor extends StatefulWidget {
  final MenuCategory category;
  final Function(String) onImageSelected;
  final Function(String) onDescriptionChanged;
  final Function(int) onProductToggled;
  
  const MenuCategoryEditor({
    Key? key,
    required this.category,
    required this.onImageSelected,
    required this.onDescriptionChanged,
    required this.onProductToggled,
  }) : super(key: key);

  @override
  State<MenuCategoryEditor> createState() => _MenuCategoryEditorState();
}

class _MenuCategoryEditorState extends State<MenuCategoryEditor> {
  final _descriptionController = TextEditingController();
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.category.description ?? '';
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // Guardar imagen en directorio de la aplicación
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      
      widget.onImageSelected(savedImage.path);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Encabezado
          ListTile(
            title: Text(
              widget.category.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${widget.category.products.length} productos'),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          
          // Contenido expandible
          if (_isExpanded) ...[
            const Divider(),
            
            // Imagen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        image: widget.category.image != null
                            ? DecorationImage(
                                image: FileImage(File(widget.category.image!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.category.image == null
                          ? const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Imagen de categoría',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.category.image != null
                              ? 'Toca para cambiar la imagen'
                              : 'Toca para agregar una imagen',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: widget.onDescriptionChanged,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Lista de productos
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Productos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Selecciona los productos para incluir en el menú',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.category.products.length,
              itemBuilder: (ctx, index) {
                final product = widget.category.products[index];
                return CheckboxListTile(
                  title: Text(product.nombre),
                  subtitle: Text(
                    '${product.precio.toStringAsFixed(2)} Bs. - ${product.clasificador}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: product.isSelected,
                  onChanged: (value) {
                    widget.onProductToggled(product.productoId);
                  },
                );
              },
            ),
            
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
