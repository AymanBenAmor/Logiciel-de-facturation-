import 'package:flutter/material.dart';
import 'dart:io'; // For File operations
import 'package:path_provider/path_provider.dart'; // For getting app directory
import 'package:csv/csv.dart'; // For CSV file handling

class DeleteArticlePage extends StatefulWidget {
  const DeleteArticlePage({super.key});

  @override
  State<DeleteArticlePage> createState() => _DeleteArticlePageState();
}

class _DeleteArticlePageState extends State<DeleteArticlePage> {
  // Controller for the reference TextField
  final TextEditingController referenceController = TextEditingController();

  // Function to get the app's documents directory
  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDirectory = Directory('${directory.path}/AchrafApp/Article');

    if (!await pdfDirectory.exists()) {
      await pdfDirectory.create(recursive: true);
    }
    return "${pdfDirectory.path}/articles.csv"; // CSV file path
  }

  // Function to delete a row based on the reference
  Future<void> deleteFromCsv() async {
    final filePath = await getFilePath();
    final file = File(filePath);

    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le fichier CSV n'existe pas !")),
      );
      return;
    }

    // Read the existing CSV file
    final existingData = await file.readAsString();
    List<List<dynamic>> csvData = const CsvToListConverter().convert(existingData);

    // Find the row to delete
    final referenceToDelete = referenceController.text.toUpperCase();
    bool found = false;

    // Filter out the row with the matching reference
    List<List<dynamic>> updatedData = csvData.where((row) {
      if (row[0] == referenceToDelete) {
        found = true; // Mark as found
        return false; // Exclude the row
      }
      return true; // Keep other rows
    }).toList();

    if (found) {
      // Convert updated data back to CSV format
      final csv = const ListToCsvConverter().convert(updatedData);
      await file.writeAsString(csv);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("L'article a été supprimé avec succès !")),
      );

      // Clear the text field
      referenceController.clear();
    } else {
      // Show error message if reference not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Référence introuvable !")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double textFieldWidth = screenWidth * 0.5;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 210, 210), // Set gray background
      appBar: AppBar(
        title: const Text('Supprimer un Article'),
        backgroundColor: const Color.fromARGB(255, 255, 89, 0),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Entrez la référence de l'article à supprimer",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 41, 41, 41),
                  ),
                ),
                const SizedBox(height: 25),

                // Référence TextField
                Container(
                  width: textFieldWidth,
                  child: TextField(
                    controller: referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Référence de l\'article',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: deleteFromCsv,
                  child: const Text('Supprimer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 89, 0),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
