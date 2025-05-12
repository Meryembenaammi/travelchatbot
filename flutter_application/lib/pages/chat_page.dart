import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [
    {"role": "bot", "text": "Bonjour ! Je suis votre assistant de voyage. Comment puis-je vous aider ?"}
  ];
  List<String> availableCities = [];
  String detectedCity = '';
  bool isLoading = false;
  Map<String, dynamic>? bookingResult;

  @override
  void initState() {
    super.initState();
    loadCities();
  }

  Future<void> loadCities() async {
    try {
      final cities = await ApiService.fetchAvailableCities();
      setState(() {
        availableCities = cities;
      });
    } catch (e) {
      print("Erreur chargement des villes : $e");
    }
  }

  Future<void> handleBooking(Map<String, dynamic> bookingData) async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.executeAction('book_hotel', bookingData);
      setState(() {
        bookingResult = result;
        messages.add({
          "role": "bot",
          "text": "Réservation effectuée avec succès !",
          "bookingResult": result
        });
      });
    } catch (e) {
      setState(() {
        messages.add({
          "role": "bot",
          "text": "Erreur lors de la réservation. Veuillez réessayer.",
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleReservationAction(String action, Map<String, dynamic> params, {String? message, Map<String, dynamic>? modification}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.executeReservationAction(action, params, message: message, modification: modification);

      // Affiche le message d'email envoyé si présent dans la réponse
      if (result['emailSent'] == true) {
        messages.add({
          "role": "bot",
          "text": action == 'modify'
              ? "📧 Email de modification envoyé"
              : "📧 Email de confirmation envoyé",
        });
      }

      setState(() {
        messages.add({
          "role": "bot",
          "text": result['response'] ?? "Action effectuée avec succès !",
          "reasoning": result['reasoning'] ?? {},
          "data": result['data'] ?? {},
          "bookingResult": result['result'] != null
              ? (result['result'] as Map).cast<String, dynamic>()
              : {},
        });
      });
    } catch (e) {
      setState(() {
        messages.add({
          "role": "bot",
          "text": "Erreur lors de l'action. Veuillez réessayer.",
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendMessage() async {
    final userInput = _controller.text.trim();
    if (userInput.isEmpty) return;

    for (String city in availableCities) {
      if (userInput.toLowerCase().contains(city.toLowerCase())) {
        detectedCity = city;
        break;
      }
    }

    setState(() {
      isLoading = true;
      messages.add({"role": "user", "text": userInput});
      _controller.clear();
    });

    try {
      final response = await ApiService.sendMessage(userInput);
      setState(() {
        messages.add({
          "role": "bot",
          "text": response['response'] ?? "Désolé, je n'ai pas pu traiter votre demande.",
          "reasoning": response['reasoning'] ?? {},
          "data": response['data'] ?? {}
        });
      });
    } catch (e) {
      print("Erreur lors de l'envoi du message : $e");
      setState(() {
        messages.add({
          "role": "bot",
          "text": "Désolé, une erreur s'est produite. Veuillez réessayer.",
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message["role"] == "user";
    final emoji = isUser ? "😊" : "🤖";
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser ? Colors.pink[100] : Colors.amber[100];

    if (isUser) {
      return Align(
        alignment: alignment,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text("$emoji ${message["text"]}"),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text("$emoji ${message["text"]}"),
        ),
        if (message["reasoning"] != null && message["reasoning"] is Map) ...[
          const SizedBox(height: 16),
          _buildReasoningSection((message["reasoning"] as Map).cast<String, dynamic>()),
        ],
        if (message["data"] != null && message["data"] is Map) ...[
          const SizedBox(height: 16),
          _buildDataSection((message["data"] as Map).cast<String, dynamic>()),
          const SizedBox(height: 8),
          _buildActionButtons((message["data"] as Map).cast<String, dynamic>()),
        ],
        if (message["bookingResult"] != null && message["bookingResult"].isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildBookingResult((message["bookingResult"] as Map).cast<String, dynamic>()),
        ],
      ],
    );
  }

  Widget _buildBookingResult(Map<String, dynamic> result) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "✅ Réservation confirmée",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text("Hôtel: ${result['hotelName'] ?? 'Non spécifié'}"),
            Text("Date d'arrivée: ${result['checkIn'] ?? 'Non spécifiée'}"),
            Text("Date de départ: ${result['checkOut'] ?? 'Non spécifiée'}"),
            Text("Numéro de confirmation: ${result['confirmationNumber'] ?? 'Non spécifié'}"),
          ],
        ),
      ),
    );
  }

  Widget _buildReasoningSection(Map<String, dynamic> reasoning) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Plan d'action"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ((reasoning['steps'] as List?) ?? []).map((step) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Étape ${step['priority'] ?? 'N/A'}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(step['action'] ?? 'Action non spécifiée'),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle("Itinéraire suggéré"),
        ...((reasoning['suggested_itinerary'] as Map<String, dynamic>?) ?? {}).entries.map((entry) {
          final day = entry.key;
          final activities = entry.value as Map<String, dynamic>;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Jour ${day.replaceAll('day', '')}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("🌅 Matin: ${(activities['morning']?['activities'] as List?)?.join(', ') ?? 'Non spécifié'}"),
                  Text("🌞 Après-midi: ${(activities['afternoon']?['activities'] as List?)?.join(', ') ?? 'Non spécifié'}"),
                  Text("🌙 Soir: ${(activities['evening']?['activities'] as List?)?.join(', ') ?? 'Non spécifié'}"),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        _buildSectionTitle("Suggestions d'hébergement"),
        ...((reasoning['hotel_suggestions'] as Map<String, dynamic>?) ?? {}).entries.map((entry) {
          final category = entry.key;
          final hotelOptions = (entry.value is Map && entry.value['options'] is List)
              ? (entry.value['options'] as List)
              : <dynamic>[];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category == 'budget'
                        ? '💰 Budget'
                        : category == 'mid_range'
                            ? '💎 Moyen de gamme'
                            : '✨ Luxe',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...hotelOptions.map((hotel) {
                    final String hotelName = hotel is String
                        ? hotel
                        : hotel['name'] ?? hotel['hotelName'] ?? 'Nom non spécifié';
                    final String location = hotel is String ? '' : hotel['location'] ?? '';
                    final String price = hotel is String
                        ? 'Prix non disponible'
                        : hotel['price'] ?? 'Prix non disponible';
                    return ListTile(
                      title: Text("• $hotelName"),
                      trailing: ElevatedButton(
                        onPressed: () => _showBookingDialog({
                          'hotelName': hotelName,
                          'location': location,
                          'price': price,
                        }),
                        child: const Text("Confirmer"),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        _buildSectionTitle("Suggestions de restaurants"),
        ...((reasoning['restaurant_suggestions'] as Map<String, dynamic>?) ?? {}).entries.map((entry) {
          final meal = entry.key;
          final restaurantOptions = (entry.value is Map && entry.value['options'] is List)
              ? (entry.value['options'] as List)
              : <dynamic>[];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal == 'breakfast'
                        ? '🌅 Petit-déjeuner'
                        : meal == 'lunch'
                            ? '🌞 Déjeuner'
                            : '🌙 Dîner',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...restaurantOptions.map((restaurant) => Text("• $restaurant")),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDataSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Données disponibles"),
        _buildSectionTitle("🏨 Hôtels disponibles"),
        ...((data['hotels'] as List?) ?? []).map((hotel) => Card(
              child: ListTile(
                title: Text(hotel['name'] ?? 'Nom non spécifié'),
                subtitle: Text(hotel['location'] ?? 'Emplacement non spécifié'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(hotel['price'] ?? 'Prix non spécifié'),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showBookingDialog({
                        'hotelName': hotel['name'] ?? hotel['hotelName'] ?? 'Nom non spécifié',
                        'location': hotel['location'] ?? '',
                        'price': hotel['price'] ?? 'Prix non disponible',
                      }),
                      child: const Text("Confirmer"),
                    ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 16),
        _buildSectionTitle("🍽️ Restaurants disponibles"),
        ...((data['restaurants'] as List?) ?? []).map((restaurant) => Card(
              child: ListTile(
                title: Text(restaurant['name'] ?? 'Nom non spécifié'),
                subtitle: Text("Note: ${restaurant['rating'] ?? 'Non noté'}"),
                trailing: Text(restaurant['price'] ?? 'Prix non spécifié'),
              ),
            )),
        const SizedBox(height: 16),
        _buildSectionTitle("🎡 Activités disponibles"),
        ...((data['activities'] as List?) ?? []).map((activity) => Card(
              child: ListTile(
                title: Text(activity['name'] ?? 'Nom non spécifié'),
                subtitle: Text(activity['description'] ?? 'Description non spécifiée'),
                trailing: Text("${activity['price'] ?? 'Prix non spécifié'} ${activity['currency'] ?? ''}"),
              ),
            )),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showBookingDialog({
            'hotelName': data['hotelName'] ?? data['name'] ?? 'Nom non spécifié',
            'location': data['location'] ?? '',
            'price': data['price'] ?? data['totalPrice'] ?? 'Prix non disponible',
          }),
          icon: const Icon(Icons.check_circle, color: Colors.green),
          label: const Text('Confirmer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[50],
            foregroundColor: Colors.green,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showModificationDialog(data),
          icon: const Icon(Icons.edit, color: Colors.orange),
          label: const Text('Modifier'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[50],
            foregroundColor: Colors.orange,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showRefusalDialog(data),
          icon: const Icon(Icons.cancel, color: Colors.red),
          label: const Text('Refuser'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[50],
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }

  void _showBookingDialog(Map<String, dynamic> data) {
    print('DEBUG HOTEL DATA: $data');
    final TextEditingController emailController = TextEditingController();
    final TextEditingController checkInController = TextEditingController();
    final TextEditingController checkOutController = TextEditingController();

    // Utiliser uniquement les champs explicitement passés
    final String hotelName = data['hotelName'] ?? 'Nom non spécifié';
    final String price = data['price'] ?? 'Prix non disponible';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la réservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Votre email'),
            ),
            TextField(
              controller: checkInController,
              decoration: const InputDecoration(labelText: 'Date d\'arrivée (YYYY-MM-DD)'),
            ),
            TextField(
              controller: checkOutController,
              decoration: const InputDecoration(labelText: 'Date de départ (YYYY-MM-DD)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isEmpty ||
                  checkInController.text.isEmpty ||
                  checkOutController.text.isEmpty) {
                // Optionnel : afficher une erreur à l'utilisateur
                return;
              }
              handleReservationAction('confirm', {
                ...data,
                'userEmail': emailController.text,
                'checkIn': checkInController.text,
                'checkOut': checkOutController.text,
                'hotelName': hotelName,
                'price': price,
              });
              Navigator.pop(context);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showModificationDialog(Map<String, dynamic> data) {
    final TextEditingController messageController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la réservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Raison de la modification',
                hintText: 'Expliquez les changements souhaités...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Nouvelle date (optionnel)',
                hintText: 'YYYY-MM-DD',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final modification = {
                if (dateController.text.isNotEmpty) 'newDates': dateController.text,
                'message': messageController.text,
              };
              handleReservationAction('modify', data, message: messageController.text, modification: modification);
              Navigator.pop(context);
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showRefusalDialog(Map<String, dynamic> data) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser la proposition'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            labelText: 'Raison du refus',
            hintText: 'Expliquez pourquoi vous refusez cette proposition...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              handleReservationAction('refuse', data, message: messageController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
            ),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("🦜", style: TextStyle(fontSize: 32)),
                SizedBox(width: 8),
                Text("SAMWay", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text("💬 Assistant de Voyage", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            if (detectedCity.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("🌍 Ville détectée : $detectedCity",
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.deepPurple)),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (context, index) => _buildMessage(messages[index]),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Décrivez votre voyage idéal...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.deepPurple),
                          onPressed: sendMessage,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}