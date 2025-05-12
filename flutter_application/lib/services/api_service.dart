import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:3000/api"; // ⚠️ Adapte si tu testes sur téléphone

  static Future<Map<String, dynamic>> sendMessage(String message) async {
    final url = Uri.parse('$baseUrl/chat');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Vérification de la structure de la réponse
      if (data['response'] == null) {
        throw Exception('Réponse invalide : champ "response" manquant');
      }

      // Construction de la réponse structurée
      return {
        'response': data['response'],
        'reasoning': data['reasoning'] ?? {
          'steps': [],
          'suggested_itinerary': {},
          'hotel_suggestions': {},
          'restaurant_suggestions': {}
        },
        'data': data['data'] ?? {
          'hotels': [],
          'restaurants': [],
          'activities': [],
          'airports': [],
          'flights': []
        }
      };
    } else {
      throw Exception('Erreur : ${response.reasonPhrase}');
    }
  }

  static Future<List<String>> fetchAvailableCities() async {
    final url = Uri.parse('$baseUrl/available-cities');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List cities = data['cities'];
      return cities.map((c) => c.toString()).toList();
    } else {
      throw Exception('Erreur récupération des villes');
    }
  }

  // Nouvelle méthode pour gérer les actions (réservations)
  static Future<Map<String, dynamic>> executeAction(String action, Map<String, dynamic> params) async {
    final url = Uri.parse('$baseUrl/chat/action');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': action,
        'params': params,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['result'] ?? {};
      } else {
        throw Exception(data['error'] ?? 'Erreur lors de l\'exécution de l\'action');
      }
    } else {
      throw Exception('Erreur serveur: ${response.reasonPhrase}');
    }
  }

  static Future<Map<String, dynamic>> executeReservationAction(
    String action,
    Map<String, dynamic> params, {
    String? message,
    Map<String, dynamic>? modification,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/reservation-action'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': action,
          'params': params,
          if (message != null) 'message': message,
          if (modification != null) 'modification': modification,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors de l\'exécution de l\'action: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'exécution de l\'action: $e');
      rethrow;
    }
  }

  // Méthode utilitaire pour formater les données
  static Map<String, dynamic> _formatData(Map<String, dynamic> rawData) {
    return {
      'hotels': _formatHotels(rawData['hotels'] ?? []),
      'restaurants': _formatRestaurants(rawData['restaurants'] ?? []),
      'activities': _formatActivities(rawData['activities'] ?? []),
      'airports': rawData['airports'] ?? [],
      'flights': rawData['flights'] ?? []
    };
  }

  static List<Map<String, dynamic>> _formatHotels(List<dynamic> hotels) {
    return hotels.map((hotel) => {
      'name': hotel['name'] ?? 'Nom non disponible',
      'location': hotel['location'] ?? 'Localisation non disponible',
      'price': hotel['price'] ?? 'Prix non disponible',
      'description': hotel['description'] ?? 'Pas de description'
    }).toList();
  }

  static List<Map<String, dynamic>> _formatRestaurants(List<dynamic> restaurants) {
    return restaurants.map((restaurant) => {
      'name': restaurant['name'] ?? 'Nom non disponible',
      'rating': restaurant['rating'] ?? 'Non noté',
      'price': restaurant['price'] ?? 'Prix non disponible',
      'cuisine': restaurant['cuisine'] ?? 'Non spécifié',
      'status': restaurant['status'] ?? 'Statut inconnu'
    }).toList();
  }

  static List<Map<String, dynamic>> _formatActivities(List<dynamic> activities) {
    return activities.map((activity) => {
      'name': activity['name'] ?? 'Nom non disponible',
      'description': activity['description'] ?? 'Pas de description',
      'price': activity['price'] ?? 'Prix non disponible',
      'currency': activity['currency'] ?? ''
    }).toList();
  }
}