import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

import '../models/menu.dart';
import '../models/promotion.dart';

class PdfService {
  Future<Uint8List> generateMenuPdf(Menu menu) async {
    final pdf = pw.Document();
    
    // Cargar fuentes
    final regularFont = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    final italicFont = await PdfGoogleFonts.nunitoItalic();
    
    // Cargar imágenes
    pw.MemoryImage? backgroundImage;
    pw.MemoryImage? headerImage;
    pw.MemoryImage? footerImage;
    
    if (menu.backgroundImage != null) {
      try {
        final bgImageBytes = await _loadImageFromPath(menu.backgroundImage!);
        backgroundImage = pw.MemoryImage(bgImageBytes);
      } catch (e) {
        print('Error loading background image: $e');
      }
    }
    
    if (menu.headerImage != null) {
      try {
        final headerImageBytes = await _loadImageFromPath(menu.headerImage!);
        headerImage = pw.MemoryImage(headerImageBytes);
      } catch (e) {
        print('Error loading header image: $e');
      }
    }
    
    if (menu.footerImage != null) {
      try {
        final footerImageBytes = await _loadImageFromPath(menu.footerImage!);
        footerImage = pw.MemoryImage(footerImageBytes);
      } catch (e) {
        print('Error loading footer image: $e');
      }
    }
    
    // Crear tema del documento
    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      italic: italicFont,
    );
    
    // Agregar página de portada
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Fondo
              if (backgroundImage != null)
                pw.Positioned.fill(
                  child: pw.Image(backgroundImage, fit: pw.BoxFit.cover),
                ),
              
              // Contenido
              pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    if (headerImage != null)
                      pw.Image(headerImage, width: 200),
                    pw.SizedBox(height: 40),
                    pw.Text(
                      menu.title,
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    if (menu.description != null)
                      pw.Text(
                        menu.description!,
                        style: const pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey800,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    pw.SizedBox(height: 40),
                    pw.Text(
                      'Fecha: ${_formatDate(menu.createdAt)}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Pie de página
              if (footerImage != null)
                pw.Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: pw.Center(
                    child: pw.Image(footerImage, width: 150),
                  ),
                ),
            ],
          );
        },
      ),
    );
    
    // Agregar páginas de categorías
    for (final category in menu.categories) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Fondo con opacidad
                if (backgroundImage != null)
                  pw.Positioned.fill(
                    child: pw.Opacity(
                      opacity: 0.1,
                      child: pw.Image(backgroundImage, fit: pw.BoxFit.cover),
                    ),
                  ),
                
                // Contenido
                pw.Padding(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Encabezado de categoría
                      
                      
                      pw.SizedBox(height: 10),
                      pw.Divider(color: PdfColors.teal300),
                      pw.SizedBox(height: 10),
                      
                      // Lista de productos
                      pw.Expanded(
                        child: pw.ListView.builder(
                          itemCount: category.products.length,
                          itemBuilder: (context, index) {
                            final product = category.products[index];
                            return pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 5),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Expanded(
                                    flex: 7,
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          product.nombre,
                                          style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        pw.SizedBox(height: 2),
                                        pw.Text(
                                          product.descripcion,
                                          style: const pw.TextStyle(
                                            fontSize: 9,
                                            color: PdfColors.grey700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 3,
                                    child: pw.Text(
                                      '${product.precio.toStringAsFixed(2)} Bs.',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Pie de página
                pw.Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        menu.title,
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'Página ${context.pageNumber} de ${context.pagesCount}',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
    
    // Agregar página de promociones si hay
    if (menu.promotions.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Fondo con opacidad
                if (backgroundImage != null)
                  pw.Positioned.fill(
                    child: pw.Opacity(
                      opacity: 0.1,
                      child: pw.Image(backgroundImage, fit: pw.BoxFit.cover),
                    ),
                  ),
                
                // Contenido
                pw.Padding(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Título de promociones
                      pw.Center(
                        child: pw.Text(
                          'PROMOCIONES ESPECIALES',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.amber800,
                          ),
                        ),
                      ),
                      
                      pw.SizedBox(height: 20),
                      
                      // Lista de promociones
                      pw.Expanded(
                        child: pw.ListView.builder(
                          itemCount: menu.promotions.length,
                          itemBuilder: (context, index) {
                            final promotion = menu.promotions[index];
                            return pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 20),
                              padding: const pw.EdgeInsets.all(10),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.amber300),
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                                color: PdfColors.amber50,
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    promotion.title,
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.amber900,
                                    ),
                                  ),
                                  
                                  if (promotion.description != null)
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.only(top: 5),
                                      child: pw.Text(
                                        promotion.description!,
                                        style: const pw.TextStyle(
                                          fontSize: 10,
                                          color: PdfColors.grey700,
                                        ),
                                      ),
                                    ),
                                  
                                  pw.SizedBox(height: 10),
                                  
                                  // Productos en la promoción
                                  ...promotion.items.map((item) => pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                    child: pw.Text(
                                      '• ${item.quantity}x ${item.product.nombre}',
                                      style: const pw.TextStyle(fontSize: 10),
                                    ),
                                  )).toList(),
                                  
                                  pw.SizedBox(height: 10),
                                  
                                  // Precios y fechas
                                  pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            'Precio original: ${promotion.originalPrice.toStringAsFixed(2)} Bs.',
                                            style: const pw.TextStyle(
                                              fontSize: 10,
                                              decoration: pw.TextDecoration.lineThrough,
                                              color: PdfColors.grey700,
                                            ),
                                          ),
                                          pw.Text(
                                            'Precio promocional: ${promotion.promotionalPrice.toStringAsFixed(2)} Bs.',
                                            style: pw.TextStyle(
                                              fontSize: 12,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.red700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                                        children: [
                                          pw.Text(
                                            'Válido desde: ${_formatDate(promotion.startDate)}',
                                            style: const pw.TextStyle(fontSize: 8),
                                          ),
                                          pw.Text(
                                            'Válido hasta: ${_formatDate(promotion.endDate)}',
                                            style: const pw.TextStyle(fontSize: 8),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Pie de página
                pw.Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        menu.title,
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'Página ${context.pageNumber} de ${context.pagesCount}',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
    
    return pdf.save();
  }
  
  Future<Uint8List> _loadImageFromPath(String path) async {
    if (path.startsWith('http')) {
      final response = await http.get(Uri.parse(path));
      return response.bodyBytes;
    } else {
      final file = File(path);
      return await file.readAsBytes();
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  Future<void> savePdf(Uint8List pdfBytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      print('PDF guardado en: ${file.path}');
    } catch (e) {
      print('Error al guardar PDF: $e');
      throw Exception('Error al guardar PDF: $e');
    }
  }
  
  Future<void> sharePdf(Uint8List pdfBytes, String fileName) async {
    try {
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    } catch (e) {
      print('Error al compartir PDF: $e');
      throw Exception('Error al compartir PDF: $e');
    }
  }
  
  Future<void> printPdf(Uint8List pdfBytes) async {
    try {
      await Printing.layoutPdf(onLayout: (_) => pdfBytes);
    } catch (e) {
      print('Error al imprimir PDF: $e');
      throw Exception('Error al imprimir PDF: $e');
    }
  }
}