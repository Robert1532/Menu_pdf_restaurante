import 'dart:convert';

class CryptoUtil {
  // Decodificar contraseña en base64
  static String decodeBase64(String encoded) {
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
  static String encodeBase64(String text) {
    return base64.encode(utf8.encode(text));
  }
}
