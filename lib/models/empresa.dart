class Empresa {
  final int empresaId;
  final String nombre;
  final String? logo;
  
  Empresa({
    required this.empresaId,
    required this.nombre,
    this.logo,
  });
  
  factory Empresa.fromJson(Map<String, dynamic> json) {
    // Usar RazonSocial como nombre si está disponible, de lo contrario usar un valor por defecto
    String nombreEmpresa = 'Empresa sin nombre';
    if (json['Nombre'] != null) {
      nombreEmpresa = json['Nombre'];
    } else if (json['RazonSocial'] != null) {
      nombreEmpresa = json['RazonSocial'];
    }
    
    return Empresa(
      empresaId: json['EmpresaId'],
      nombre: nombreEmpresa,
      logo: json['Logo'],
    );
  }
}
