import 'package:achraf_app/BL.dart';
import 'package:achraf_app/Delete_page.dart';
import 'package:achraf_app/add_client.dart';
import 'package:achraf_app/add_product.dart';
import 'package:achraf_app/bon_sortie.dart';
import 'package:achraf_app/delete_client.dart';
import 'package:achraf_app/display_clients.dart';
import 'package:achraf_app/display_products.dart';
import 'package:achraf_app/facture.dart';
import 'package:achraf_app/passager.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late String _currentTime;
  bool _isHoveredAdd = false; // Track hover state for the "+" button
  bool _isHoveredRemove = false; // Track hover state for the "-" button
  bool _isHoveredList = false;

  bool _isHoveredAdd_client = false; // Track hover state for the "+" button
  bool _isHoveredRemove_client = false; // Track hover state for the "-" button
  bool _isHoveredList_client = false;

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    // Update the time every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute}:${now.second}';
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Set the button size proportional to the screen width and height
    double buttonWidth = screenWidth * 0.15; // 25% of screen width
    double buttonHeight = screenHeight * 0.12; // 10% of screen height
    double spaceBetweenButtons = screenWidth * 0.05; // 5% of screen width

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'), // Path to the image in assets
            fit: BoxFit.fill, // Ensures the image covers the entire screen
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FacturePage()),
                  );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(buttonWidth, buttonHeight), // Set the button size dynamically
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255), 
                    backgroundColor: const Color.fromARGB(200, 255, 89, 0),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.white, // Border color
                        width: 2, // Border width
                      ),
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                  ),
                  child: const Text('Facture', style: TextStyle(fontSize: 20)),
                ),
              
              SizedBox(width: spaceBetweenButtons), // Space between the buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BL_Page()),
                  );
                  
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255), 
                  backgroundColor: const Color.fromARGB(200, 255, 89, 0), 
                  minimumSize: Size(buttonWidth, buttonHeight), // Set the button size dynamically
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.white, // Border color
                      width: 2, // Border width
                    ),
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
                child: const Text('Bon De Livraison', style: TextStyle(fontSize: 20)),
              ),
              SizedBox(width: spaceBetweenButtons), // Space between the buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => passagerPage()),
                  );
                    
                  },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(buttonWidth, buttonHeight), // Set the button size dynamically
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255), 
                  backgroundColor: const Color.fromARGB(200, 255, 89, 0), 
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.white, // Border color
                      width: 2, // Border width
                    ),
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
                child: const Text('Passager', style: TextStyle(fontSize: 20)),
              ),
              SizedBox(width: spaceBetweenButtons), // Space between the buttons
              ElevatedButton(
                onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BonSortiePage()),
                  );
                  },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(buttonWidth, buttonHeight), // Set the button size dynamically
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255), 
                  backgroundColor: const Color.fromARGB(200, 255, 89, 0), 
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.white, // Border color
                      width: 2, // Border width
                    ),
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
                child: const Text('Bon De Sortie', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
      // Add a floating action button at the bottom right with a border
      floatingActionButton: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: MouseRegion(
              onEnter: (_) {
                setState(() {
                  _isHoveredAdd = true; // Show the rectangle for "+" button when hovered
                });
              },
              onExit: (_) {
                setState(() {
                  _isHoveredAdd = false; // Hide the rectangle for "+" button when the cursor exits
                });
              },
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddArticlePage()),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 255, 89, 0), // Same color as the buttons
                child: const Icon(Icons.add, size: 30, color: Colors.white), // "+" symbol
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.white, // Border color for the button
                    width: 2, // Border width
                  ),
                  borderRadius: BorderRadius.circular(30), // Rounded border for the floating action button
                ),
              ),
            ),
          ),
           Positioned(
            right: 0,
            bottom: 70,
            child: MouseRegion(
              onEnter: (_) {
                setState(() {
                  _isHoveredRemove = true; // Show the rectangle for "+" button when hovered
                  
                });
              },
              onExit: (_) {
                setState(() {
                  _isHoveredRemove = false; // Hide the rectangle for "+" button when the cursor exits
                });
              },
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DeleteArticlePage()),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 255, 89, 0), // Same color as the buttons
                child: const Icon(Icons.remove, size: 30, color: Colors.white), // "+" symbol
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.white, // Border color for the button
                    width: 2, // Border width
                  ),
                  borderRadius: BorderRadius.circular(30), // Rounded border for the floating action button
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 140,
            child: MouseRegion(
              onEnter: (_) {
                setState(() {
                  _isHoveredList = true; // Show the rectangle for "+" button when hovered
                  
                });
              },
              onExit: (_) {
                setState(() {
                  _isHoveredList = false; // Hide the rectangle for "+" button when the cursor exits
                });
              },
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ViewArticlesPage()),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 255, 89, 0), // Same color as the buttons
                child: const Icon(Icons.list_alt_outlined, size: 30, color: Colors.white), // "+" symbol
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.white, // Border color for the button
                    width: 2, // Border width
                  ),
                  borderRadius: BorderRadius.circular(30), // Rounded border for the floating action button
                ),
              ),
            ),
          ),

          // time
          Positioned(
            right: 16,
            top: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

      /// right buttons
      /// add client button 
    Positioned(
            left: 30,
            bottom: 0,
            child: MouseRegion(
              onEnter: (_) {
                setState(() {
                  _isHoveredAdd_client = true; // Show the rectangle for "+" button when hovered
                });
              },
              onExit: (_) {
                setState(() {
                  _isHoveredAdd_client = false; // Hide the rectangle for "+" button when the cursor exits
                });
              },
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddClientPage()),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 255, 89, 0), // Same color as the buttons
                child: const Icon(Icons.add, size: 30, color: Colors.white), // "+" symbol
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.white, // Border color for the button
                    width: 2, // Border width
                  ),
                  borderRadius: BorderRadius.circular(30), // Rounded border for the floating action button
                ),
              ),
            ),
          ),

          //remove client button
           Positioned(
            left: 30,
            bottom: 70,
            child: MouseRegion(
              onEnter: (_) {
                setState(() {
                  _isHoveredRemove_client = true; // Show the rectangle for "+" button when hovered
                  
                });
              },
              onExit: (_) {
                setState(() {
                  _isHoveredRemove_client = false; // Hide the rectangle for "+" button when the cursor exits
                });
              },
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DeleteClientPage()),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 255, 89, 0), // Same color as the buttons
                child: const Icon(Icons.remove, size: 30, color: Colors.white), // "+" symbol
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.white, // Border color for the button
                    width: 2, // Border width
                  ),
                  borderRadius: BorderRadius.circular(30), // Rounded border for the floating action button
                ),
              ),
            ),
          ),

          // list clients button
          Positioned(
            left: 30,
            bottom: 140,
            child: MouseRegion(
              onEnter: (_) {
                setState(() {
                  _isHoveredList_client = true; // Show the rectangle for "+" button when hovered
                  
                });
              },
              onExit: (_) {
                setState(() {
                  _isHoveredList_client = false; // Hide the rectangle for "+" button when the cursor exits
                });
              },
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ViewClientPage()),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 255, 89, 0), // Same color as the buttons
                child: const Icon(Icons.list_alt_outlined, size: 30, color: Colors.white), // "+" symbol
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.white, // Border color for the button
                    width: 2, // Border width
                  ),
                  borderRadius: BorderRadius.circular(30), // Rounded border for the floating action button
                ),
              ),
            ),
          ),

          // Display the rectangle next to the "+" button when hovered
          if (_isHoveredAdd)
            Positioned(
              right: 60,
              bottom: 12.5, // Adjust based on the position of the "+" button
              child: Container(
                width: 180, // Width of the rectangle
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 89, 0), // Orange color for the rectangle
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Ajouter un article", // Text inside the rectangle
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          // Display the rectangle next to the "-" button when hovered
          if (_isHoveredRemove)
            Positioned(
              right: 60,
              bottom: 82.5, // Adjust based on the position of the "-" button
              child: Container(
                width: 180, // Width of the rectangle
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 89, 0), // Orange color for the rectangle
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Supprimer un article", // Text inside the rectangle
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            if (_isHoveredList)
            Positioned(
              right: 60,
              bottom: 152.5, // Adjust based on the position of the "-" button
              child: Container(
                width: 200, // Width of the rectangle
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 89, 0), // Orange color for the rectangle
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Afficher tous les articles", // Text inside the rectangle
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),




            if (_isHoveredAdd_client)
            Positioned(
              left: 90,
              bottom: 12.5, // Adjust based on the position of the "+" button
              child: Container(
                width: 180, // Width of the rectangle
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 89, 0), // Orange color for the rectangle
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Ajouter un client", // Text inside the rectangle
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            if (_isHoveredRemove_client)
            Positioned(
              left: 90,
              bottom: 82.5, // Adjust based on the position of the "+" button
              child: Container(
                width: 180, // Width of the rectangle
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 89, 0), // Orange color for the rectangle
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Supprimer un client", // Text inside the rectangle
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            if (_isHoveredList_client)
            Positioned(
              left: 90,
              bottom: 152.5, // Adjust based on the position of the "-" button
              child: Container(
                width: 200, // Width of the rectangle
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 89, 0), // Orange color for the rectangle
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Afficher tous les clients", // Text inside the rectangle
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position at bottom right
      
    );
  }
}
