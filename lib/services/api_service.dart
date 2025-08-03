import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart'; // For debugPrint

class ApiService {
  // Updated to use ngrok URL
  static const String _ngrokUrl = 'https://949f2637a966.ngrok-free.app';

  static String get baseUrl {
    return '$_ngrokUrl/api';
  }
  
  // Common headers for ngrok
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true', // Skip ngrok browser warning
  };

  // Login user
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Login failed: ${response.statusCode} - ${response.body}');
        return {'success': false, 'message': 'Login failed'};
      }
    } catch (e) {
      debugPrint('Network error during login: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Add crime with image support (sending Base64 strings)
  static Future<bool> addCrime(Map<String, dynamic> crimeData, List<Uint8List> images) async {
    try {
      // Convert Uint8List images to Base64 strings
      List<String> base64Images = images.map((bytes) => base64Encode(bytes)).toList();
      
      // Add Base64 images to crimeData map
      crimeData['images'] = base64Images;

      debugPrint('Sending crime data: ${jsonEncode(crimeData)}'); // Log outgoing data

      final response = await http.post(
        Uri.parse('$baseUrl/crimes'),
        headers: _headers,
        body: jsonEncode(crimeData),
      );
      
      debugPrint('Add crime response status: ${response.statusCode}');
      debugPrint('Add crime response body: ${response.body}');
      
      if (response.statusCode == 200) {
        debugPrint('Crime added successfully!');
        return true;
      } else {
        debugPrint('Failed to add crime: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding crime: $e');
      return false;
    }
  }

  // New: Update crime record
  static Future<bool> updateCrime(String id, Map<String, dynamic> crimeData) async {
    try {
      debugPrint('Sending update crime data for ID $id: ${jsonEncode(crimeData)}');
      final response = await http.put(
        Uri.parse('$baseUrl/crimes/$id'),
        headers: _headers,
        body: jsonEncode(crimeData),
      );

      debugPrint('Update crime response status: ${response.statusCode}');
      debugPrint('Update crime response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Crime updated successfully!');
        return true;
      } else {
        debugPrint('Failed to update crime: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating crime: $e');
      return false;
    }
  }

  // Get all crimes
  static Future<List<dynamic>> getAllCrimes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/crimes'),
        headers: _headers,
      );
      
      debugPrint('Get all crimes response status: ${response.statusCode}');
      debugPrint('Get all crimes response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to fetch crimes: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching crimes: $e');
      return [];
    }
  }

  // Search crimes by type
  static Future<List<dynamic>> searchCrimesByType(String crimeType) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/crimes/search?query=$crimeType'),
        headers: _headers,
      );
      
      debugPrint('Search crimes response status: ${response.statusCode}');
      debugPrint('Search crimes response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to search crimes: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error searching crimes: $e');
      return [];
    }
  }
}