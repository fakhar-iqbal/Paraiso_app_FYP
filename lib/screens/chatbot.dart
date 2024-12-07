// import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:sqflite/sqflite.dart';

// class FoodChatbot extends StatefulWidget {
//   @override
//   _FoodChatbotState createState() => _FoodChatbotState();
// }

// class _FoodChatbotState extends State<FoodChatbot> {
//   final TextEditingController _messageController = TextEditingController();
//   final List<ChatMessage> _messages = [];
  
//   late DatabaseHelper _dbHelper;
//   late Gemini _gemini;

//   @override
//   void initState() {
//     super.initState();
//     _dbHelper = DatabaseHelper();
//     _gemini = Gemini.instance;
//     _initializeDatabase();
//   }

//   Future<void> _initializeDatabase() async {
//     await _dbHelper.initializeDatabase();
//   }

//   Future<String> _generateContextAwareResponse(String userQuery) async {
//     try {
//       // Fetch relevant restaurant and dish data from database
//       List<Map<String, dynamic>> relevantData = await _dbHelper.searchRelevantData(userQuery);
      
//       // If no data found, return a conversational response
//       if (relevantData.isEmpty) {
//         return "Sorry, I couldn't find any information about that. Would you like to try another search?";
//       }
      
//       // Construct context for AI
//       String context = relevantData.map((item) => 
//         "Restaurant: ${item['restaurant_name']}, "
//         "Dish: ${item['dish_name']}, "
//         "Price: ${item['price']} PKR, "
//         "Size: ${item['size']}"
//       ).join('\n');

//       // Prepare enhanced prompt
//       String enhancedPrompt = """
//       You are a helpful food assistant. 
//       Context of available dishes:
//       $context

//       User Query: $userQuery

//       Provide a friendly, informative response based on the available context.
//       """;

//       // Generate AI response
//       final response = await _gemini.chat([
//         Content(
//           role: 'user',
//           parts: [Parts(text: enhancedPrompt)]
//         )
//       ]);

//       return response?.content?.parts?.first?.text ?? 
//             "Sorry, I couldn't process your request.";

//     } catch (e) {
//       print("Gemini API Error: $e");
//       return "An error occurred while processing your request.";
//     }
//   }

//   void _sendMessage() async {
//     if (_messageController.text.isEmpty) return;

//     setState(() {
//       _messages.add(ChatMessage(
//         text: _messageController.text,
//         isUserMessage: true,
//       ));
//     });

//     String response = await _generateContextAwareResponse(_messageController.text);

//     setState(() {
//       _messages.add(ChatMessage(
//         text: response,
//         isUserMessage: false,
//       ));
//     });

//     _messageController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Food Chatbot')),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return _buildMessageWidget(_messages[index]);
//               },
//             ),
//           ),
//           _buildMessageInputArea(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageWidget(ChatMessage message) {
//     return Align(
//       alignment: message.isUserMessage 
//         ? Alignment.centerRight 
//         : Alignment.centerLeft,
//       child: Container(
//         margin: EdgeInsets.all(8),
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: message.isUserMessage ? Colors.blue[100] : Colors.green[100],
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Text(message.text),
//       ),
//     );
//   }

//   Widget _buildMessageInputArea() {
//     return Padding(
//       padding: EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               decoration: InputDecoration(
//                 hintText: 'Ask about food...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.send),
//             onPressed: _sendMessage,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChatMessage {
//   final String text;
//   final bool isUserMessage;

//   ChatMessage({required this.text, required this.isUserMessage});
// }

// class DatabaseHelper {
//   late Database _database;

//   Future<void> initializeDatabase() async {
//     _database = await openDatabase(
//       'food_database.db',
//       version: 1,
//       onCreate: (Database db, int version) async {
//         await db.execute('''
//           CREATE TABLE restaurants (
//             id INTEGER PRIMARY KEY,
//             restaurant_name TEXT,
//             dish_name TEXT,
//             price REAL,
//             size TEXT,
//             picture TEXT
//           )
//         ''');
        
//         // Optional: Insert sample data
//         await _insertSampleData(db);
//       },
//     );
//   }

//   Future<void> _insertSampleData(Database db) async {
//     await db.insert('restaurants', {
//       'restaurant_name': 'KFC',
//       'dish_name': 'Zinger Burger',
//       'price': 1000.0,
//       'size': 'Regular',
//       'picture': 'kfc_zinger.png'
//     });
//     // Add more sample data as needed
//   }

//   Future<List<Map<String, dynamic>>> searchRelevantData(String query) async {
//     return await _database.rawQuery('''
//       SELECT * FROM restaurants 
//       WHERE LOWER(restaurant_name) LIKE LOWER(?) OR LOWER(dish_name) LIKE LOWER(?)
//     ''', ['%$query%', '%$query%']);
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:flutter_animate/flutter_animate.dart';

// class FoodChatbot extends StatefulWidget {
//   @override
//   _FoodChatbotState createState() => _FoodChatbotState();
// }

// class _FoodChatbotState extends State<FoodChatbot> with SingleTickerProviderStateMixin {
//   final TextEditingController _messageController = TextEditingController();
//   final List<ChatMessage> _messages = [];
//   final FocusNode _messageFocusNode = FocusNode();
  
//   late DatabaseHelper _dbHelper;
//   late Gemini _gemini;
//   late AnimationController _typingAnimationController;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _dbHelper = DatabaseHelper();
//     _gemini = Gemini.instance;
//     _initializeDatabase();

//     // Initialize typing animation controller
//     _typingAnimationController = AnimationController(
//       duration: Duration(seconds: 1),
//       vsync: this,
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _messageFocusNode.dispose();
//     _typingAnimationController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeDatabase() async {
//     await _dbHelper.initializeDatabase();
//   }

//   Future<String> _generateContextAwareResponse(String userQuery) async {
//     try {
//       // Fetch relevant restaurant and dish data from database
//       List<Map<String, dynamic>> relevantData = await _dbHelper.searchRelevantData(userQuery);
      
//       // If no data found, return a conversational response
//       if (relevantData.isEmpty) {
//         return "Sorry, I couldn't find any information about that. Would you like to try another search?";
//       }
      
//       // Construct context for AI
//       String context = relevantData.map((item) => 
//         "Restaurant: ${item['restaurant_name']}, "
//         "Dish: ${item['dish_name']}, "
//         "Price: ${item['price']} PKR, "
//         "Size: ${item['size']}"
//       ).join('\n');

//       // Prepare enhanced prompt
//       String enhancedPrompt = """
//       You are a helpful food assistant. 
//       Context of available dishes:
//       $context

//       User Query: $userQuery

//       Provide a friendly, informative response based on the available context.
//       """;

//       // Generate AI response
//       final response = await _gemini.chat([
//         Content(
//           role: 'user',
//           parts: [Parts(text: enhancedPrompt)]
//         )
//       ]);

//       return response?.content?.parts?.first?.text ?? 
//             "Sorry, I couldn't process your request.";

//     } catch (e) {
//       print("Gemini API Error: $e");
//       return "An error occurred while processing your request.";
//     }
//   }

//   void _sendMessage() async {
//     if (_messageController.text.isEmpty) return;

//     // Dismiss keyboard
//     _messageFocusNode.unfocus();

//     // Add user message
//     setState(() {
//       _messages.add(ChatMessage(
//         text: _messageController.text,
//         isUserMessage: true,
//       ));
//       _isLoading = true;
//     });

//     // Clear input
//     _messageController.clear();

//     // Get response
//     String response = await _generateContextAwareResponse(_messages.last.text);

//     // Add bot response
//     setState(() {
//       _isLoading = false;
//       _messages.add(ChatMessage(
//         text: response,
//         isUserMessage: false,
//       ));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF5F5F5),
//       appBar: AppBar(
//         title: Text(
//           'Food Buddy',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.deepOrange,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               itemCount: _messages.length + (_isLoading ? 1 : 0),
//               itemBuilder: (context, index) {
//                 // If loading, add typing indicator
//                 if (_isLoading && index == _messages.length) {
//                   return _buildTypingIndicator();
//                 }

//                 // Regular message
//                 return _buildMessageWidget(_messages[index])
//                   .animate()
//                   .fadeIn(duration: Duration(milliseconds: 300))
//                   .slideX(begin: 0.1, end: 0);
//               },
//               reverse: false,
//             ),
//           ),
//           _buildMessageInputArea(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTypingIndicator() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: EdgeInsets.only(left: 16, bottom: 16),
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               spreadRadius: 1,
//               blurRadius: 5,
//             )
//           ],
//         ),
//         child: AnimatedTextKit(
//           animatedTexts: [
//             TyperAnimatedText(
//               '...',
//               textStyle: TextStyle(
//                 fontSize: 20,
//                 color: Colors.deepOrange,
//               ),
//               speed: Duration(milliseconds: 200),
//             ),
//           ],
//           isRepeatingAnimation: true,
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageWidget(ChatMessage message) {
//     return Align(
//       alignment: message.isUserMessage 
//         ? Alignment.centerRight 
//         : Alignment.centerLeft,
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 8),
//         constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
//         decoration: BoxDecoration(
//           color: message.isUserMessage 
//             ? Color(0xFFE3F2FD)  // Light Blue for User
//             : Color(0xFFF0F4C3),  // Light Green for Bot
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 5,
//               offset: Offset(0, 2),
//             )
//           ],
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Text(
//           message.text,
//           style: TextStyle(
//             color: Colors.black87,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageInputArea() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: Offset(0, -2),
//           )
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               focusNode: _messageFocusNode,
//               decoration: InputDecoration(
//                 hintText: 'Ask about food...',
//                 hintStyle: TextStyle(color: Colors.grey),
//                 filled: true,
//                 fillColor: Color(0xFFF5F5F5),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//               ),
//               textInputAction: TextInputAction.send,
//               onSubmitted: (_) => _sendMessage(),
//             ),
//           ),
//           SizedBox(width: 10),
//           CircleAvatar(
//             backgroundColor: Colors.deepOrange,
//             radius: 25,
//             child: IconButton(
//               icon: Icon(Icons.send, color: Colors.white),
//               onPressed: _sendMessage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChatMessage {
//   final String text;
//   final bool isUserMessage;

//   ChatMessage({required this.text, required this.isUserMessage});
// }

// class DatabaseHelper {
//   late Database _database;

//   Future<void> initializeDatabase() async {
//     _database = await openDatabase(
//       'food_database.db',
//       version: 1,
//       onCreate: (Database db, int version) async {
//         await db.execute('''
//           CREATE TABLE restaurants (
//             id INTEGER PRIMARY KEY,
//             restaurant_name TEXT,
//             dish_name TEXT,
//             price REAL,
//             size TEXT,
//             picture TEXT
//           )
//         ''');
        
//         // Optional: Insert sample data
//         await _insertSampleData(db);
//       },
//     );
//   }

//   Future<void> _insertSampleData(Database db) async {
//     await db.insert('restaurants', {
//       'restaurant_name': 'KFC',
//       'dish_name': 'Zinger Burger',
//       'price': 1000.0,
//       'size': 'Regular',
//       'picture': 'kfc_zinger.png'
//     });
//     // Add more sample data as needed
//   }

//   Future<List<Map<String, dynamic>>> searchRelevantData(String query) async {
//     return await _database.rawQuery('''
//       SELECT * FROM restaurants 
//       WHERE LOWER(restaurant_name) LIKE LOWER(?) OR LOWER(dish_name) LIKE LOWER(?)
//     ''', ['%$query%', '%$query%']);
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:flutter_animate/flutter_animate.dart';

// class FoodChatbot extends StatefulWidget {
//   @override
//   _FoodChatbotState createState() => _FoodChatbotState();
// }

// class _FoodChatbotState extends State<FoodChatbot> with SingleTickerProviderStateMixin {
//   final TextEditingController _messageController = TextEditingController();
//   final List<ChatMessage> _messages = [];
//   final FocusNode _messageFocusNode = FocusNode();
  
//   late DatabaseHelper _dbHelper;
//   late Gemini _gemini;
//   late AnimationController _typingAnimationController;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _dbHelper = DatabaseHelper();
//     _gemini = Gemini.instance;
//     _initializeDatabase();

//     // Initialize typing animation controller
//     _typingAnimationController = AnimationController(
//       duration: Duration(seconds: 1),
//       vsync: this,
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _messageFocusNode.dispose();
//     _typingAnimationController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeDatabase() async {
//     await _dbHelper.initializeDatabase();
//   }

//   Future<String> _generateContextAwareResponse(String userQuery) async {
//     try {
//       // Fetch relevant restaurant and dish data from database
//       List<Map<String, dynamic>> relevantData = await _dbHelper.searchRelevantData(userQuery);
      
//       // If no data found, return a conversational response
//       if (relevantData.isEmpty) {
//         return "Sorry, I couldn't find any information about that. Would you like to try another search?";
//       }
      
//       // Construct context for AI
//       String context = relevantData.map((item) => 
//         "Restaurant: ${item['restaurant_name']}, "
//         "Dish: ${item['dish_name']}, "
//         "Price: ${item['price']} PKR, "
//         "Size: ${item['size']}"
//       ).join('\n');

//       // Prepare enhanced prompt
//       String enhancedPrompt = """
//       You are a helpful food assistant. 
//       Context of available dishes:
//       $context

//       User Query: $userQuery

//       Provide a friendly, informative response based on the available context.
//       """;

//       // Generate AI response
//       final response = await _gemini.chat([
//         Content(
//           role: 'user',
//           parts: [Parts(text: enhancedPrompt)]
//         )
//       ]);

//       return response?.content?.parts?.first?.text ?? 
//             "Sorry, I couldn't find any information about that. Would you like to try another search?";

//     } catch (e) {
//       print("Gemini API Error: $e");
//       return "Sorry, I couldn't process your request.";
//     }
//   }

//   void _sendMessage() async {
//     if (_messageController.text.isEmpty) return;

//     // Dismiss keyboard
//     _messageFocusNode.unfocus();

//     // Add user message
//     setState(() {
//       _messages.add(ChatMessage(
//         text: _messageController.text,
//         isUserMessage: true,
//       ));
//       _isLoading = true;
//     });

//     // Clear input
//     _messageController.clear();

//     // Simulate typing for 2 seconds before response
//     await Future.delayed(Duration(seconds: 2));

//     // Get response
//     String response = await _generateContextAwareResponse(_messages.last.text);

//     // Add bot response
//     setState(() {
//       _isLoading = false;
//       _messages.add(ChatMessage(
//         text: response,
//         isUserMessage: false,
//       ));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Dark Theme Configuration
//     ThemeData darkTheme = ThemeData(
//       brightness: Brightness.dark,
//       scaffoldBackgroundColor: Color(0xFF121212),
//       appBarTheme: AppBarTheme(
//         backgroundColor: Color(0xFF1E1E1E),
//         elevation: 0,
//       ),
//       colorScheme: ColorScheme.dark(
//         primary: Color(0xFF2C2C2C),
//         secondary: Color.fromARGB(255, 167, 166, 166),
//         surface: Color(0xFF1E1E1E),
//       ),
//     );

//     return Theme(
//       data: darkTheme,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'Food Buddy',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           centerTitle: true,
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 itemCount: _messages.length + (_isLoading ? 1 : 0),
//                 itemBuilder: (context, index) {
//                   // If loading, add typing indicator
//                   if (_isLoading && index == _messages.length) {
//                     return _buildTypingIndicator();
//                   }

//                   // Regular message
//                   return _buildMessageWidget(_messages[index])
//                     .animate()
//                     .fadeIn(duration: Duration(milliseconds: 300))
//                     .slideX(begin: 0.1, end: 0);
//                 },
//                 reverse: false,
//               ),
//             ),
//             _buildMessageInputArea(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTypingIndicator() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: EdgeInsets.only(left: 16, bottom: 16),
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: Color(0xFF2C2C2C),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               spreadRadius: 1,
//               blurRadius: 5,
//             )
//           ],
//         ),
//         child: AnimatedTextKit(
//           animatedTexts: [
//             TyperAnimatedText(
//               '...',
//               textStyle: TextStyle(
//                 fontSize: 20,
//                 color: Colors.white70,
//               ),
//               speed: Duration(milliseconds: 200),
//             ),
//           ],
//           isRepeatingAnimation: true,
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageWidget(ChatMessage message) {
//     return Align(
//       alignment: message.isUserMessage 
//         ? Alignment.centerRight 
//         : Alignment.centerLeft,
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 8),
//         constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
//         decoration: BoxDecoration(
//           color: message.isUserMessage 
//             ? Color.fromARGB(255, 62, 178, 255)  // Dark color for User
//             : Color.fromARGB(255, 1, 65, 61),  // Slightly different dark color for Bot
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 5,
//               offset: Offset(0, 2),
//             )
//           ],
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Text(
//           message.text,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageInputArea() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Color(0xFF1E1E1E),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: Offset(0, -2),
//           )
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               focusNode: _messageFocusNode,
//               decoration: InputDecoration(
//                 hintText: 'Ask about food...',
//                 hintStyle: TextStyle(color: Colors.grey),
//                 filled: true,
//                 fillColor: Color(0xFF2C2C2C),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//               ),
//               textInputAction: TextInputAction.send,
//               onSubmitted: (_) => _sendMessage(),
//             ),
//           ),
//           SizedBox(width: 10),
//           CircleAvatar(
//             backgroundColor: Color.fromARGB(255, 4, 100, 92),
//             radius: 25,
//             child: IconButton(
//               icon: Icon(Icons.send, color: Colors.white),
//               onPressed: _sendMessage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class ChatMessage {
//   final String text;
//   final bool isUserMessage;

//   ChatMessage({required this.text, required this.isUserMessage});
// }

// class DatabaseHelper {
//   late Database _database;

//   Future<void> initializeDatabase() async {
//     _database = await openDatabase(
//       'food_database.db',
//       version: 1,
//       onCreate: (Database db, int version) async {
//         await db.execute('''
//           CREATE TABLE restaurants (
//             id INTEGER PRIMARY KEY,
//             restaurant_name TEXT,
//             dish_name TEXT,
//             price REAL,
//             size TEXT,
//             picture TEXT
//           )
//         ''');
        
//         // Optional: Insert sample data
//         await _insertSampleData(db);
//       },
//     );
//   }

//   Future<void> _insertSampleData(Database db) async {
//     await db.insert('restaurants', {
//       'restaurant_name': 'KFC',
//       'dish_name': 'Zinger Burger',
//       'price': 1000.0,
//       'size': 'Regular',
//       'picture': 'kfc_zinger.png'
//     });
//     // Add more sample data as needed
//   }

//   Future<List<Map<String, dynamic>>> searchRelevantData(String query) async {
//     return await _database.rawQuery('''
//       SELECT * FROM restaurants 
//       WHERE LOWER(restaurant_name) LIKE LOWER(?) OR LOWER(dish_name) LIKE LOWER(?)
//     ''', ['%$query%', '%$query%']);
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:paraiso/screens/database_services.dart';


class FoodChatbot extends StatefulWidget {
  @override
  _FoodChatbotState createState() => _FoodChatbotState();
}

class _FoodChatbotState extends State<FoodChatbot> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final FocusNode _messageFocusNode = FocusNode();
  
  late DatabaseHelper _dbHelper;
  late Gemini _gemini;
  late AnimationController _typingAnimationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
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
    // Normalize query
    String normalizedQuery = userQuery.toLowerCase().trim();

    // Handle greetings and small talk
    if (_isGreeting(normalizedQuery)) {
      return _generateGreetingResponse();
    }

    // Search for restaurants or items
    List<Map<String, dynamic>> restaurantResults = 
      await _dbHelper.searchRestaurants(normalizedQuery);
    List<Map<String, dynamic>> itemResults = 
      await _dbHelper.searchItems(normalizedQuery);

    // Prepare context and response
    String context = _prepareContext(restaurantResults, itemResults);

    try {
      // Prepare enhanced prompt
      String enhancedPrompt = """
      You are a friendly and helpful food assistant. 
      Context of available information:
      $context

      User Query: $userQuery

      Provide a helpful, conversational, and precise response based on the available context. 
      If no specific information is found, engage in friendly conversation about food.
      """;

      // Generate AI response
      final response = await _gemini.chat([
        Content(
          role: 'user',
          parts: [Parts(text: enhancedPrompt)]
        )
      ]);

      return response?.content?.parts?.first?.text ?? 
            "I'm not sure about that. Would you like to try another query?";

    } catch (e) {
      print("Gemini API Error: $e");
      return "Sorry, I'm having trouble processing your request right now.";
    }
  }

  bool _isGreeting(String query) {
    List<String> greetings = [
      'hi', 'hello', 'hey', 'greetings', 'what\'s up', 'wassup'
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

  String _prepareContext(
    List<Map<String, dynamic>> restaurantResults, 
    List<Map<String, dynamic>> itemResults
  ) {
    StringBuffer context = StringBuffer();

    // Add restaurant details
    for (var restaurant in restaurantResults) {
      context.write("Restaurant: ${restaurant['restaurantDetails']['name']}\n");
      context.write("Address: ${restaurant['restaurantDetails']['address']}\n");
      context.write("Category: ${restaurant['restaurantDetails']['category']}\n");
      
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
      context.write("Discount: ${item['itemDetails']['discount'] ?? 'No discount'}\n");
      context.write("Prices: Small: ${item['itemDetails']['prices']['Small'] ?? 'N/A'}, ");
      context.write("Medium: ${item['itemDetails']['prices']['Medium'] ?? 'N/A'}, ");
      context.write("Large: ${item['itemDetails']['prices']['Large'] ?? 'N/A'}\n\n");
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

  // Rest of the previous UI code remains the same (from the original implementation)
  // ... [Include all the previous build methods: build(), _buildTypingIndicator(), 
  //      _buildMessageWidget(), _buildMessageInputArea()]
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
      alignment: message.isUserMessage 
        ? Alignment.centerRight 
        : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUserMessage 
            ? Color.fromARGB(255, 62, 178, 255)  // Dark color for User
            : Color.fromARGB(255, 1, 65, 61),  // Slightly different dark color for Bot
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
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Color.fromARGB(255, 4, 100, 92),
            radius: 25,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
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