import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:paraiso/screens/camera_screen.dart';
import 'package:paraiso/services/database_helper.dart';

class FoodChatbot extends StatefulWidget {
  @override
  _FoodChatbotState createState() => _FoodChatbotState();
}

class _FoodChatbotState extends State<FoodChatbot>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final FocusNode _messageFocusNode = FocusNode();

  late AdvancedDatabaseHelper _dbHelper;
  late Gemini _gemini;
  late AnimationController _typingAnimationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dbHelper = AdvancedDatabaseHelper();
    _gemini = Gemini.instance;

    // Initialize typing animation controller
    _typingAnimationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  Future<String> _generateContextAwareResponse(String userQuery) async {
    try {
      // Handle greetings first
      if (_isGreeting(userQuery.toLowerCase().trim())) {
        return _generateGreetingResponse();
      }

      // Ensure database helper is properly initialized
      if (_dbHelper == null) {
        _dbHelper = AdvancedDatabaseHelper();
      }

      // Use new advanced database helper
      QueryResult result = await _dbHelper.processQuery(userQuery);

      // Check if result is null
      if (result == null) {
        return "I'm sorry, I couldn't process your query.";
      }

      // Intelligent response formatting
      switch (result.type) {
        case 'item_availability':
          return _formatAvailabilityResponse(result.data!);
        case 'restaurant_availability':
          return _formatRestaurantAvailabilityResponse(result.data!);
        case 'restaurants':
          return _formatRestaurantResponse(result.data!);
        case 'menu_items':
          return _formatMenuItemResponse(result.data!);
        case 'discounts':
          return _formatDiscountResponse(result.data!);
        case 'cuisine':
          return _formatCuisineResponse(result.data!);
        case 'fuzzy_search':
          return _formatFuzzySearchResponse(result.data!);
        case 'error':
          // Log the specific error message for debugging
          print("Database query error: ${result.message}");
          return result.message ?? "An unknown error occurred.";
        default:
          return "I'm sorry, I couldn't understand your query. Could you please rephrase?";
      }
    } catch (e, stackTrace) {
      // More detailed error logging
      print("Error in _generateContextAwareResponse: $e");
      print("Stacktrace: $stackTrace");

      return "I'm sorry, I encountered an unexpected error. Please try again.";
    }
  }
// Detailed formatting methods

  String _formatAvailabilityResponse(
      List<Map<String, dynamic>> availableItems) {
    if (availableItems.isEmpty) {
      return "Currently, no menu items are available.";
    }

    // Group items by restaurant
    Map<String, List<String>> restaurantItems = {};
    for (var item in availableItems) {
      String restaurantName = item['restaurant'] ?? 'Unknown Restaurant';
      String itemName = item['name'] ?? 'Unnamed Item';

      if (!restaurantItems.containsKey(restaurantName)) {
        restaurantItems[restaurantName] = [];
      }
      restaurantItems[restaurantName]!.add(itemName);
    }

    // Build response
    StringBuffer response = StringBuffer();
    response.writeln("Available Menu Items:");

    restaurantItems.forEach((restaurant, items) {
      response.writeln("\n$restaurant:");
      for (var item in items) {
        response.writeln("- $item");
      }
    });

    response.writeln("\nTotal available items: ${availableItems.length}");
    return response.toString();
  }

  String _formatRestaurantAvailabilityResponse(
      List<Map<String, dynamic>> restaurants) {
    if (restaurants.isEmpty) {
      return "No restaurant information is currently available.";
    }

    StringBuffer response = StringBuffer();
    response.writeln("Restaurant Status:");

    for (var restaurant in restaurants) {
      String name = restaurant['name'] ?? 'Unnamed Restaurant';
      String openingHours = restaurant['openingHrs'] ?? 'Hours Not Available';
      String status = restaurant['status'] ?? 'Unknown';

      response.writeln("\n$name:");
      response.writeln("- Opening Hours: $openingHours");
      response.writeln("- Current Status: $status");
    }

    response.writeln("\nTotal restaurants: ${restaurants.length}");
    return response.toString();
  }

  String _formatRestaurantResponse(List<Map<String, dynamic>> restaurants) {
    if (restaurants.isEmpty) return "No restaurants found.";

    return "🍽️ Restaurant Results:\n" +
        restaurants
            .map((r) => "• ${r['name']}\n"
                "  Address: ${r['address'] ?? 'Address not available'}\n"
                "  Category: ${r['category'] ?? 'Not specified'}\n"
                "  ${r.containsKey('openingHrs') ? 'Hours: ${r['openingHrs']}' : ''}\n"
                "  ${r.containsKey('contact') ? 'Contact: ${r['contact']}' : ''}")
            .join('\n');
  }

  String _formatMenuItemResponse(List<Map<String, dynamic>> menuItems) {
    if (menuItems.isEmpty) return "No menu items found.";

    return "🍲 Menu Items:\n" +
        menuItems
            .map((item) => "• ${item['name']} at ${item['restaurant']}\n"
                "  Price: \$${item['price']}\n"
                "  Type: ${item['type']}\n"
                "  Calories: ${item['calories'] ?? 'Not available'}")
            .join('\n');
  }

  String _formatDiscountResponse(List<Map<String, dynamic>> discounts) {
    if (discounts.isEmpty) return "No current discounts available.";

    return "💸 Current Discounts:\n" +
        discounts
            .map((discount) =>
                "• ${discount['name']} at ${discount['restaurant']}\n"
                "  Original Price: \$${discount['originalPrice']}\n"
                "  Discount: ${discount['discount']}%")
            .join('\n');
  }

  String _formatCuisineResponse(List<Map<String, dynamic>> cuisineRestaurants) {
    if (cuisineRestaurants.isEmpty)
      return "No restaurants found in that cuisine category.";

    return "🌍 Cuisine Restaurants:\n" +
        cuisineRestaurants
            .map((restaurant) => "• ${restaurant['name']}\n"
                "  Cuisine: ${restaurant['category']}")
            .join('\n');
  }

  String _formatFuzzySearchResponse(List<Map<String, dynamic>> searchResults) {
    if (searchResults.isEmpty) return "No matches found for your query.";

    return "🔍 Search Results:\n" +
        searchResults
            .map((result) => "• ${result['name']} (${result['type']})\n"
                "  ${result['type'] == 'restaurant' ? 'Address: ${result['address']}' : 'Restaurant: ${result['restaurant']}'}")
            .join('\n');
  }

  bool _isGreeting(String query) {
    List<String> greetings = [
      'hi',
      'hello',
      'hey',
      'greetings',
      'what\'s up',
      'wassup'
    ];
    return greetings.contains(query);
  }

  String _generateGreetingResponse() {
    List<String> responses = [
      "Hello there! I'm your friendly Food Buddy. How can I help you today?",
      "Hi! Welcome to Food Buddy. Looking for some delicious recommendations?",
      "Hey! Craving something tasty? I'm here to help you find the perfect meal.",
      "Greetings! Ready to explore some amazing food options?"
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  String _prepareContext(List<Map<String, dynamic>> restaurantResults,
      List<Map<String, dynamic>> itemResults) {
    StringBuffer context = StringBuffer();

    // Add restaurant details
    for (var restaurant in restaurantResults) {
      context.write("Restaurant: ${restaurant['restaurantDetails']['name']}\n");
      context.write("Address: ${restaurant['restaurantDetails']['address']}\n");
      context
          .write("Category: ${restaurant['restaurantDetails']['category']}\n");

      // Add items for this restaurant
      if (restaurant['items'] != null) {
        context.write("Items:\n");
        for (var item in restaurant['items']) {
          context.write("- ${item['name']} ");
          context.write("(Discount: ${item['discount'] ?? 'No discount'}) ");
          context.write("(Price: Small: ${item['prices']['Small'] ?? 'N/A'}, ");
          context.write("Medium: ${item['prices']['Medium'] ?? 'N/A'}, ");
          context.write("Large: ${item['prices']['Large'] ?? 'N/A'})\n");
        }
      }
      context.write("\n");
    }

    // Add specific item details
    for (var item in itemResults) {
      context.write("Item: ${item['itemDetails']['name']}\n");
      context.write("Restaurant: ${item['restaurantDetails']['name']}\n");
      context.write("Type: ${item['itemDetails']['type']}\n");
      context.write(
          "Discount: ${item['itemDetails']['discount'] ?? 'No discount'}\n");
      context.write(
          "Prices: Small: ${item['itemDetails']['prices']['Small'] ?? 'N/A'}, ");
      context.write(
          "Medium: ${item['itemDetails']['prices']['Medium'] ?? 'N/A'}, ");
      context.write(
          "Large: ${item['itemDetails']['prices']['Large'] ?? 'N/A'}\n\n");
    }

    return context.toString();
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    // Dismiss keyboard
    _messageFocusNode.unfocus();

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text,
        isUserMessage: true,
      ));
      _isLoading = true;
    });

    // Clear input
    _messageController.clear();

    // Simulate typing for 2 seconds before response
    await Future.delayed(Duration(seconds: 2));

    // Get response
    String response = await _generateContextAwareResponse(_messages.last.text);

    // Add bot response
    setState(() {
      _isLoading = false;
      _messages.add(ChatMessage(
        text: response,
        isUserMessage: false,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dark Theme Configuration
    ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
      ),
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF2C2C2C),
        secondary: Color.fromARGB(255, 167, 166, 166),
        surface: Color(0xFF1E1E1E),
      ),
    );

    return Theme(
      data: darkTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Food Buddy',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  // If loading, add typing indicator
                  if (_isLoading && index == _messages.length) {
                    return _buildTypingIndicator();
                  }

                  // Regular message
                  return _buildMessageWidget(_messages[index])
                      .animate()
                      .fadeIn(duration: Duration(milliseconds: 300))
                      .slideX(begin: 0.1, end: 0);
                },
                reverse: false,
              ),
            ),
            _buildMessageInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: 16, bottom: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 1,
              blurRadius: 5,
            )
          ],
        ),
        child: AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              '...',
              textStyle: TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
              speed: Duration(milliseconds: 200),
            ),
          ],
          isRepeatingAnimation: true,
        ),
      ),
    );
  }

  Widget _buildMessageWidget(ChatMessage message) {
    return Align(
      alignment:
          message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUserMessage
              ? Color.fromARGB(255, 62, 178, 255) // Dark color for User
              : Color.fromARGB(
                  255, 1, 65, 61), // Slightly different dark color for Bot
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          message.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _messageFocusNode,
              decoration: InputDecoration(
                hintText: 'Ask about food...',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF2C2C2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.grey.shade300,
              size: 22,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CameraScreen()));
            },
          ),
          SizedBox(width: 5),
          CircleAvatar(
            backgroundColor: Color.fromARGB(255, 4, 100, 92),
            radius: 22,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUserMessage;

  ChatMessage({required this.text, required this.isUserMessage});
}
