import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/empresa.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  User? _user;
  List<Empresa> _empresas = [];
  int? _selectedEmpresaId;
  bool _isLoading = true;
  
  final AuthService _authService = AuthService();
  
  AuthProvider() {
    _autoLogin();
  }
  
  bool get isAuth => _token != null;
  bool get isLoading => _isLoading;
  String? get token => _token;
  User? get user => _user;
  List<Empresa> get empresas => _empresas;
  int? get selectedEmpresaId => _selectedEmpresaId;
  
  Empresa? get selectedEmpresa {
  if (_selectedEmpresaId == null || _empresas.isEmpty) return null;

  try {
    return _empresas.firstWhere(
      (empresa) => empresa.empresaId == _selectedEmpresaId,
      orElse: () => _empresas.first,
    );
  } catch (e) {
    print('Error al obtener empresa seleccionada: $e');
    return null;
  }
}

  
  Future<void> _autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!prefs.containsKey('userData')) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    final userData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData['expiryDate']);
    
    if (expiryDate.isBefore(DateTime.now())) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    _token = userData['token'];
    _user = User.fromJson(userData['user']);
    
    try {
      _empresas = (userData['empresas'] as List<dynamic>)
          .map((item) => Empresa.fromJson(item))
          .toList();
    } catch (e) {
      print('Error al cargar empresas: $e');
      _empresas = [];
    }
    
    _selectedEmpresaId = userData['selectedEmpresaId'];
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> login(String username, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final authData = await _authService.login(username, password);
      
      _token = authData['token'];
      _user = authData['user'];
      _empresas = authData['empresas'];
      
      // Si solo hay una empresa, seleccionarla automáticamente
      if (_empresas.length == 1) {
        _selectedEmpresaId = _empresas.first.empresaId;
      }
      
      final prefs = await SharedPreferences.getInstance();
      
      // Preparar datos de empresas para guardar
      final empresasData = _empresas.map((empresa) => {
        'EmpresaId': empresa.empresaId,
        'Nombre': empresa.nombre,
        'Logo': empresa.logo,
      }).toList();
      
      final userData = json.encode({
        'token': _token,
        'user': {
          'UsuarioId': _user!.usuarioId,
          'Username': _user!.username,
          'Password': _user!.password,
          'IsActivo': _user!.isActivo,
          'PersonaId': _user!.personaId,
          'EmpresaIds': _user!.empresaIds,
        },
        'empresas': empresasData,
        'selectedEmpresaId': _selectedEmpresaId,
        'expiryDate': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      });
      
      await prefs.setString('userData', userData);
      
      _isLoading = false;
      notifyListeners(); // Esto debería desencadenar la redirección
      print('Login completado, isAuth = $isAuth');
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      print('Error de login: $error'); // Añadir log para depuración
      throw error;
    }
  }
  
  Future<void> logout() async {
    _token = null;
    _user = null;
    _empresas = [];
    _selectedEmpresaId = null;
    
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    
    notifyListeners();
  }
  
  void selectEmpresa(int empresaId) async {
    _selectedEmpresaId = empresaId;
    
    // Actualizar preferencias
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      final userData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
      userData['selectedEmpresaId'] = _selectedEmpresaId;
      await prefs.setString('userData', json.encode(userData));
    }
    
    notifyListeners();
  }
}
