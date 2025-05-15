class Product {
  final int productoId;
  final int empresaId;
  final String codigo;
  final String categoria;
  final String clasificador;
  final String nombre;
  final String descripcion;
  final int tiempo;
  final int contPreferencia;
  final bool isFavorito;
  final bool isDisponible;
  final bool isElaboracion;
  final bool isDescontinuado;
  final int unidadMedidaId;
  final int estadoProducto;
  final String? codigoImportacion;
  final String codigoActividadSIN;
  final String codigoProductoSIN;
  final bool? isCodificable;
  final double precio;
  final double? saldoTotal;
  final DateTime createdAt;
  final int createUserId;
  final DateTime? updatedAt;
  final int? updateUserId;
  final DateTime? deletedAt;
  final int? deleteUserId;
  final int? tipoProductoServicio;
  
  // Para la selección en el menú
  bool isSelected;
  int quantity;
  
  Product({
    required this.productoId,
    required this.empresaId,
    required this.codigo,
    required this.categoria,
    required this.clasificador,
    required this.nombre,
    required this.descripcion,
    required this.tiempo,
    required this.contPreferencia,
    required this.isFavorito,
    required this.isDisponible,
    required this.isElaboracion,
    required this.isDescontinuado,
    required this.unidadMedidaId,
    required this.estadoProducto,
    this.codigoImportacion,
    required this.codigoActividadSIN,
    required this.codigoProductoSIN,
    this.isCodificable,
    required this.precio,
    this.saldoTotal,
    required this.createdAt,
    required this.createUserId,
    this.updatedAt,
    this.updateUserId,
    this.deletedAt,
    this.deleteUserId,
    this.tipoProductoServicio,
    this.isSelected = false,
    this.quantity = 1,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productoId: json['ProductoId'],
      empresaId: json['EmpresaId'],
      codigo: json['Codigo'],
      categoria: json['Categoria'],
      clasificador: json['Clasificador'],
      nombre: json['Nombre'],
      descripcion: json['Descripcion'],
      tiempo: json['Tiempo'],
      contPreferencia: json['ContPreferencia'],
      isFavorito: json['IsFavorito'],
      isDisponible: json['IsDisponible'],
      isElaboracion: json['IsElaboracion'],
      isDescontinuado: json['IsDescontinuado'],
      unidadMedidaId: json['UnidadMedidaId'],
      estadoProducto: json['EstadoProducto'],
      codigoImportacion: json['CodigoImportacion'],
      codigoActividadSIN: json['CodigoActividadSIN'],
      codigoProductoSIN: json['CodigoProductoSIN'],
      isCodificable: json['IsCodificable'],
      precio: json['Precio'].toDouble(),
      saldoTotal: json['SaldoTotal']?.toDouble(),
      createdAt: DateTime.parse(json['CreatedAt']),
      createUserId: json['CreateUserId'],
      updatedAt: json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt']) : null,
      updateUserId: json['UpdateUserId'],
      deletedAt: json['DeletedAt'] != null ? DateTime.parse(json['DeletedAt']) : null,
      deleteUserId: json['DeleteUserId'],
      tipoProductoServicio: json['TipoProductoServicio'],
    );
  }
}
