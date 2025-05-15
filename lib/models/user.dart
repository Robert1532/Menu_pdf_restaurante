class User {
  final int usuarioId;
  final String username;
  final String password;
  final bool isActivo;
  final int personaId;
  final String empresaIds;
  final DateTime? createdAt;
  final int? createAtUsuarioId;
  final DateTime? updatedAt;
  final int? updatedAtUsuarioId;
  final DateTime? deletedAt;
  final int? deleteAtUsuarioId;
  
  User({
    required this.usuarioId,
    required this.username,
    required this.password,
    required this.isActivo,
    required this.personaId,
    required this.empresaIds,
    this.createdAt,
    this.createAtUsuarioId,
    this.updatedAt,
    this.updatedAtUsuarioId,
    this.deletedAt,
    this.deleteAtUsuarioId,
  });
  
  List<int> get empresaIdList {
    return empresaIds.split(',').map((id) => int.parse(id)).toList();
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      usuarioId: json['UsuarioId'],
      username: json['Username'],
      password: json['Password'],
      isActivo: json['IsActivo'],
      personaId: json['PersonaId'],
      empresaIds: json['EmpresaIds'],
      createdAt: json['CreateAt'] != null ? DateTime.parse(json['CreateAt']) : null,
      createAtUsuarioId: json['CreateAtUsuarioId'],
      updatedAt: json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt']) : null,
      updatedAtUsuarioId: json['UpdatedAtUsuarioId'],
      deletedAt: json['DeleteAt'] != null ? DateTime.parse(json['DeleteAt']) : null,
      deleteAtUsuarioId: json['DeleteAtUsuarioId'],
    );
  }
}
