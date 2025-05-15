import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../providers/product_provider.dart';
import '../providers/menu_provider.dart';
import '../models/menu.dart';
import '../models/promotion.dart';
import '../services/pdf_service.dart';
import '../widgets/menu_category_editor.dart';
import '../widgets/promotion_editor.dart';

class MenuEditorScreen extends StatefulWidget {
  const MenuEditorScreen({Key? key}) : super(key: key);

  @override
  State<MenuEditorScreen> createState() => _MenuEditorScreenState();
}

class _MenuEditorScreenState extends State<MenuEditorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isGeneratingPdf = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Inicializar controladores con valores actuales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      if (menuProvider.currentMenu != null) {
        _titleController.text = menuProvider.currentMenu!.title;
        _descriptionController.text = menuProvider.currentMenu!.description ?? '';
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage(ImageType type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      
      // Guardar imagen en directorio de la aplicación
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      
      switch (type) {
        case ImageType.background:
          menuProvider.updateMenuBackground(savedImage.path);
          break;
        case ImageType.header:
          menuProvider.updateMenuHeader(savedImage.path);
          break;
        case ImageType.footer:
          menuProvider.updateMenuFooter(savedImage.path);
          break;
      }
    }
  }
  
  Future<void> _generatePdf() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    
    setState(() {
      _isGeneratingPdf = true;
    });
    
    try {
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      final pdfService = PdfService();
      
      final pdfBytes = await pdfService.generateMenuPdf(menuProvider.currentMenu!);
      
      // Guardar PDF
      final fileName = '${menuProvider.currentMenu!.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await pdfService.savePdf(pdfBytes, fileName);
      
      // Compartir PDF
      await pdfService.sharePdf(pdfBytes, fileName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final menu = menuProvider.currentMenu;
    
    if (menu == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Tabs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'General'),
                Tab(text: 'Categorías'),
                Tab(text: 'Promociones'),
              ],
            ),
            
            // Contenido
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab General
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información General',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título del Menú',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un título';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            menuProvider.updateMenuTitle(value);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción (opcional)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            menuProvider.updateMenuDescription(value);
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Imágenes',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildImageSelector(
                          title: 'Imagen de Fondo',
                          description: 'Se mostrará como fondo en todas las páginas',
                          imagePath: menu.backgroundImage,
                          onTap: () => _pickImage(ImageType.background),
                        ),
                        const SizedBox(height: 16),
                        _buildImageSelector(
                          title: 'Imagen de Encabezado',
                          description: 'Se mostrará en la portada del menú',
                          imagePath: menu.headerImage,
                          onTap: () => _pickImage(ImageType.header),
                        ),
                        const SizedBox(height: 16),
                        _buildImageSelector(
                          title: 'Imagen de Pie',
                          description: 'Se mostrará al final de la portada',
                          imagePath: menu.footerImage,
                          onTap: () => _pickImage(ImageType.footer),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tab Categorías
                  menu.categories.isEmpty
                      ? const Center(child: Text('No hay categorías disponibles'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: menu.categories.length,
                          itemBuilder: (ctx, index) {
                            return MenuCategoryEditor(
                              category: menu.categories[index],
                              onImageSelected: (imagePath) {
                                menuProvider.updateCategoryImage(
                                  menu.categories[index].name,
                                  imagePath,
                                );
                              },
                              onDescriptionChanged: (description) {
                                menuProvider.updateCategoryDescription(
                                  menu.categories[index].name,
                                  description,
                                );
                              },
                              onProductToggled: (productId) {
                                menuProvider.toggleProductInMenu(
                                  menu.categories[index].name,
                                  productId,
                                );
                              },
                            );
                          },
                        ),
                  
                  // Tab Promociones
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Promociones',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                final productProvider = Provider.of<ProductProvider>(context, listen: false);
                                final availableProducts = productProvider.products.where((p) => p.isDisponible).toList();
                                
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  builder: (ctx) => PromotionEditor(
                                    promotion: Promotion.empty(),
                                    availableProducts: availableProducts,
                                    onSave: (promotion) {
                                      menuProvider.addPromotion(promotion);
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Nueva Promoción'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        menu.promotions.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.local_offer_outlined,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No hay promociones',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Crea promociones para mostrar ofertas especiales en tu menú',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: menu.promotions.length,
                                itemBuilder: (ctx, index) {
                                  final promotion = menu.promotions[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  promotion.title,
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit),
                                                    onPressed: () {
                                                      final productProvider = Provider.of<ProductProvider>(context, listen: false);
                                                      final availableProducts = productProvider.products.where((p) => p.isDisponible).toList();
                                                      
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled: true,
                                                        shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                                        ),
                                                        builder: (ctx) => PromotionEditor(
                                                          promotion: promotion,
                                                          availableProducts: availableProducts,
                                                          onSave: (updatedPromotion) {
                                                            menuProvider.updatePromotion(index, updatedPromotion);
                                                            Navigator.of(ctx).pop();
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, color: Colors.red),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (ctx) => AlertDialog(
                                                          title: const Text('Eliminar Promoción'),
                                                          content: const Text('¿Estás seguro que deseas eliminar esta promoción?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.of(ctx).pop(),
                                                              child: const Text('Cancelar'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                menuProvider.removePromotion(index);
                                                                Navigator.of(ctx).pop();
                                                              },
                                                              child: const Text('Eliminar'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (promotion.description != null && promotion.description!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(promotion.description!),
                                            ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Productos:',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...promotion.items.map((item) => Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Text('• ${item.quantity}x ${item.product.nombre}'),
                                          )).toList(),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Precio original: ${promotion.originalPrice.toStringAsFixed(2)} Bs.',
                                                    style: const TextStyle(
                                                      decoration: TextDecoration.lineThrough,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Precio promocional: ${promotion.promotionalPrice.toStringAsFixed(2)} Bs.',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Desde: ${_formatDate(promotion.startDate)}',
                                                    style: Theme.of(context).textTheme.bodySmall,
                                                  ),
                                                  Text(
                                                    'Hasta: ${_formatDate(promotion.endDate)}',
                                                    style: Theme.of(context).textTheme.bodySmall,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isGeneratingPdf ? null : _generatePdf,
        icon: _isGeneratingPdf
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white),
              )
            : const Icon(Icons.picture_as_pdf),
        label: const Text('Generar PDF'),
      ),
    );
  }
  
  Widget _buildImageSelector({
    required String title,
    required String description,
    String? imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                image: imagePath != null
                    ? DecorationImage(
                        image: FileImage(File(imagePath)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imagePath == null
                  ? const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (imagePath != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Toca para cambiar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

enum ImageType {
  background,
  header,
  footer,
}
