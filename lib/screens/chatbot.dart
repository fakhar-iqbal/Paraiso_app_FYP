import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String sender; // 'user' or 'bot'
  final String text;
  final bool isImage;

  ChatMessage({
    required this.sender,
    required this.text,
    this.isImage = false,
  });
}

class FoodChatbot extends StatefulWidget {
  const FoodChatbot({super.key});

  @override
  State<FoodChatbot> createState() => _FoodChatbotState();
}

class _FoodChatbotState extends State<FoodChatbot> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  List<ChatMessage> messages = [
    ChatMessage(
        sender: 'bot',
        text: 'Hello! I am your food assistant. How can I help you today?')
  ];
  List<Map<String, dynamic>> _restaurantData = [];

  @override
  void initState() {
    super.initState();
    _fetchRestaurantData();
  }

  // Future<void> _fetchRestaurantData() async {
  //   try {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('restaurantAdmins')
  //         .get();

  //     List<Map<String, dynamic>> restaurants = [];

  //     for (var doc in querySnapshot.docs) {
  //       var data = doc.data() as Map<String, dynamic>;

  //       // Fetch the items subcollection
  //       List<Map<String, dynamic>> items = [];
  //       var itemsSnapshot = await FirebaseFirestore.instance
  //           .collection('restaurantAdmins')
  //           .doc(doc.id)
  //           .collection('items')
  //           .get();

  //       for (var itemDoc in itemsSnapshot.docs) {
  //         var itemData = itemDoc.data();
  //         items.add(itemData);
  //       }

  //       data['items'] = items; // Add the items to the restaurant data
  //       restaurants.add(data);
  //     }

  //     setState(() {
  //       _restaurantData = restaurants;
  //       print('Fetched ${_restaurantData.length} restaurants with items.');
  //     });
  //   } catch (e) {
  //     print('Error fetching restaurant data: $e');
  //     setState(() {
  //       messages.add(ChatMessage(
  //         sender: 'bot',
  //         text: 'Could not load restaurant data. Please try again later.',
  //       ));
  //     });
  //   }
  // }

  Map<String, dynamic> _convertFirestoreData(Map<String, dynamic> data) {
    data.forEach((key, value) {
      if (value is GeoPoint) {
        data[key] = {
          'latitude': value.latitude,
          'longitude': value.longitude,
        };
      } else if (value is Timestamp) {
        data[key] = value
            .toDate()
            .toIso8601String(); // Convert Timestamp to ISO8601 string
      } else if (value is Map<String, dynamic>) {
        data[key] = _convertFirestoreData(value);
      }
    });
    return data;
  }

  Future<void> _fetchRestaurantData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('restaurantAdmins').get();

      List<Map<String, dynamic>> restaurants = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Convert GeoPoint and Timestamp in restaurant data
        data = _convertFirestoreData(data);

        // Fetch the items subcollection
        List<Map<String, dynamic>> items = [];
        var itemsSnapshot = await FirebaseFirestore.instance
            .collection('restaurantAdmins')
            .doc(doc.id)
            .collection('items')
            .get();

        for (var itemDoc in itemsSnapshot.docs) {
          var itemData = itemDoc.data();

          // Convert GeoPoint and Timestamp in item data
          itemData = _convertFirestoreData(itemData);

          items.add(itemData);
        }

        data['items'] = items; // Add the items to the restaurant data
        restaurants.add(data);
      }

      setState(() {
        _restaurantData = restaurants;
        print('Fetched ${_restaurantData.length} restaurants with items.');
      });
    } catch (e) {
      print('Error fetching restaurant data: $e');
      setState(() {
        messages.add(ChatMessage(
          sender: 'bot',
          text: 'Could not load restaurant data. Please try again later.',
        ));
      });
    }
  }

  Future<String> resizeAndEncodeImage(File imageFile) async {
    try {
      // Read the image file as bytes
      final bytes = await imageFile.readAsBytes();
      // Decode the image using the image package
      final originalImage = img.decodeImage(bytes);

      // More aggressive resizing and compression
      final resizedImage = img.copyResize(originalImage!,
          width: 400, // Reduce width further
          interpolation: img.Interpolation.average);

      // Reduce JPEG quality for smaller file size
      final resizedBytes = img.encodeJpg(resizedImage, quality: 50);

      // Convert the resized image bytes to Base64
      return base64Encode(resizedBytes);
    } catch (e) {
      print('Error resizing and encoding image: $e');
      throw Exception('Image processing failed');
    }
  }

  Future<void> _sendMessage({String? text, File? imageFile}) async {
    if ((text == null || text.trim().isEmpty) && imageFile == null) {
      return;
    }

    if (imageFile != null) {
      setState(() {
        messages.add(ChatMessage(
          sender: 'user',
          text: imageFile.path,
          isImage: true,
        ));
      });
    } else if (text != null && text.trim().isNotEmpty) {
      setState(() {
        messages.add(ChatMessage(sender: 'user', text: text.trim()));
      });
    }

    _controller.clear();
    setState(() {
      _isLoading = true;
    });

    try {
      String? base64Image;
      if (imageFile != null) {
        // final bytes = await imageFile.readAsBytes();
        // base64Image = base64Encode(bytes);
        base64Image = await resizeAndEncodeImage(imageFile);
      }

      final url = imageFile != null
          ? 'http://192.168.110.92:3000/query-with-image'
          : 'http://192.168.110.92:3000/query';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': text ?? '',
          'restaurants': _restaurantData,
          if (base64Image != null) 'image': base64Image,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          messages.add(ChatMessage(
            sender: 'bot',
            text: responseData['reply'] ?? 'Sorry, I couldn\'t process that.',
          ));
        });
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error processing message: $e');
      setState(() {
        messages.add(ChatMessage(
          sender: 'bot',
          text: 'Sorry, there was an error processing your request.',
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
    bool isUser = message.sender == 'user';
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = isUser
        ? const Color.fromARGB(255, 143, 38, 6)
        : const Color.fromARGB(255, 46, 123, 162);
    final textColor = Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: alignment,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: message.isImage
              ? Image.file(File(message.text), fit: BoxFit.cover)
              : Text(
                  message.text,
                  style: TextStyle(color: textColor),
                ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[messages.length - 1 - index];
        return _buildMessageBubble(msg);
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.photo, color: Colors.white),
            onPressed: () async {
              final pickedFile =
                  await _picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                File image = File(pickedFile.path);
                await _sendMessage(imageFile: image);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () async {
              final pickedFile =
                  await _picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                File image = File(pickedFile.path);
                await _sendMessage(imageFile: image);
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask about a dish or restaurant...',
                hintStyle: const TextStyle(color: Colors.grey,fontSize: 15),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 143, 38, 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {
              _sendMessage(text: _controller.text);
            },
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paraiso Assistant',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Recoleta',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 143, 38, 6),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildMessageList()),
              _buildInputBar(),
            ],
          ),
          if (_isLoading)
            LinearProgressIndicator(
              backgroundColor: Colors.grey[800],
              color: const Color.fromARGB(255, 116, 44, 22),
            ),
        ],
      ),
    );
  }
}
