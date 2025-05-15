import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/user.dart';
import '../models/empresa.dart';

class AuthService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
  
  // Decodificar contraseña en base64
  String _decodeBase64(String encoded) {
    try {
      // Asegurarse de que la cadena tenga una longitud válida para base64
      String normalizedBase64 = encoded;
      while (normalizedBase64.length % 4 != 0) {
        normalizedBase64 += '=';
      }
      
      return utf8.decode(base64.decode(normalizedBase64));
    } catch (e) {
      print('Error decodificando base64: $e');
      return encoded; // Si no es base64, devolver el original
    }
  }
  
  // Codificar contraseña en base64
  String _encodeBase64(String text) {
    return base64.encode(utf8.encode(text));
  }
  
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('Intentando login con usuario: $username');
      print('URL de API: $baseUrl');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/usuarios'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Respuesta de API: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> usersJson = json.decode(response.body);
        print('Usuarios obtenidos: ${usersJson.length}');
        
        final List<User> users = usersJson.map((json) => User.fromJson(json)).toList();
        
        // Buscar usuario por nombre de usuario
        User? foundUser;
        try {
          foundUser = users.firstWhere(
            (user) => user.username.toLowerCase() == username.toLowerCase(),
          );
          print('Usuario encontrado: ${foundUser.username}');
        } catch (e) {
          print('Usuario no encontrado');
          throw Exception('Usuario no encontrado');
        }
        
        // Verificar si el usuario está activo
        if (!foundUser.isActivo) {
          print('Usuario inactivo');
          throw Exception('Usuario inactivo');
        }
        
        // Decodificar contraseña almacenada y comparar
        final decodedPassword = _decodeBase64(foundUser.password);
        print('Comparando contraseñas: $decodedPassword vs $password');
        
        if (decodedPassword != password) {
          print('Contraseña incorrecta');
          throw Exception('Contraseña incorrecta');
        }
        
        print('Autenticación exitosa, obteniendo empresas');
        try {
          // Obtener empresas del usuario
          final empresas = await _getEmpresas(foundUser.empresaIdList);
          print('Empresas obtenidas: ${empresas.length}');
          
          return {
            'user': foundUser,
            'empresas': empresas,
            'token': _generateToken(foundUser),
          };
        } catch (e) {
          print('Error al obtener empresas: $e');
          // Si hay un error al obtener empresas, creamos una lista vacía
          // para que el usuario pueda continuar
          return {
            'user': foundUser,
            'empresas': <Empresa>[],
            'token': _generateToken(foundUser),
          };
        }
      } else {
        print('Error HTTP: ${response.statusCode}');
        throw Exception('Error al obtener usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en login: $e');
      throw Exception('Error de autenticación: $e');
    }
  }
  
  Future<List<Empresa>> _getEmpresas(List<int> empresaIds) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/erpempresas'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> empresasJson = json.decode(response.body);
        print('JSON de empresas recibido: $empresasJson');
        
        // Crear empresas directamente sin validación adicional
        final List<Empresa> allEmpresas = [];
        for (var json in empresasJson) {
          try {
            if (json['EmpresaId'] != null) {
              allEmpresas.add(Empresa.fromJson(json));
            }
          } catch (e) {
            print('Error al procesar empresa: $e');
          }
        }
        
        print('Total de empresas procesadas: ${allEmpresas.length}');
        
        // Si no hay empresas en la API, crear empresas manualmente basadas en los IDs
        if (allEmpresas.isEmpty) {
          print('No se encontraron empresas en la API, creando empresas manualmente');
          for (var id in empresaIds) {
            allEmpresas.add(Empresa(
              empresaId: id,
              nombre: 'Empresa $id',
            ));
          }
        }
        
        // Filtrar empresas por IDs del usuario
        final filteredEmpresas = allEmpresas.where((empresa) => 
          empresaIds.contains(empresa.empresaId)
        ).toList();
        
        print('Empresas filtradas para los IDs $empresaIds: ${filteredEmpresas.length}');
        
        // Si no hay empresas después del filtrado, usar todas las empresas disponibles
        if (filteredEmpresas.isEmpty && allEmpresas.isNotEmpty) {
          print('No se encontraron empresas para los IDs específicos, usando todas las disponibles');
          return allEmpresas;
        }
        
        return filteredEmpresas;
      } else {
        print('Error al obtener empresas: ${response.statusCode}');
        
        // Si hay un error, crear empresas manualmente basadas en los IDs
        final List<Empresa> manualEmpresas = [];
        for (var id in empresaIds) {
          manualEmpresas.add(Empresa(
            empresaId: id,
            nombre: 'Empresa $id',
          ));
        }
        return manualEmpresas;
      }
    } catch (e) {
      print('Error en _getEmpresas: $e');
      
      // Si hay una excepción, crear empresas manualmente basadas en los IDs
      final List<Empresa> manualEmpresas = [];
      for (var id in empresaIds) {
        manualEmpresas.add(Empresa(
          empresaId: id,
          nombre: 'Empresa $id',
        ));
      }
      return manualEmpresas;
    }
  }
  
  String _generateToken(User user) {
    // Simulación simple de token JWT
    final payload = {
      'sub': user.usuarioId,
      'username': user.username,
      'empresaIds': user.empresaIds,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000,
    };
    
    return base64.encode(utf8.encode(json.encode(payload)));
  }
}
