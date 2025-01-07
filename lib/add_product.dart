import 'package:flutter/material.dart';
import 'dart:io'; // For File operations
import 'package:path_provider/path_provider.dart'; // For getting app directory
import 'package:csv/csv.dart'; // For CSV file handling

class AddArticlePage extends StatefulWidget {
  const AddArticlePage({super.key});

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  // Controllers for TextFields
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
 

  // Function to get the app's documents directory
  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDirectory = Directory('${directory.path}/AchrafApp/Article');

    if (!await pdfDirectory.exists()) {
      await pdfDirectory.create(recursive: true);
    }

    return "${pdfDirectory.path}/articles.csv"; // CSV file path
  }

  // Function to validate inputs
  bool validateInputs() {
    // Ensure no field except "Remise" is empty
  if (referenceController.text.isEmpty ||
      designationController.text.isEmpty ||
      priceController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires !")),
    );
    return false;
  }

  

    // Ensure "Prix Unitaire" is numeric
    if (double.tryParse(priceController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le prix unitaire doit être un nombre valide !")),
      );
      return false;
    }

   

    return true; // All validations passed
  }

  // Function to save data to CSV file
  Future<void> saveToCsv() async {
  final filePath = await getFilePath();
  final file = File(filePath);

  
  // Create a row with data from the text fields
  final newReference = referenceController.text;
  final newRow = [
    newReference.toUpperCase(),
    designationController.text.toUpperCase(),
    priceController.text,
    
  ];

  // Check if the file exists
  if (await file.exists()) {
    // If the file exists, read the existing data
    final existingData = await file.readAsString();
    List<List<dynamic>> csvData = const CsvToListConverter().convert(existingData);

    // Check if the reference already exists
    for (var row in csvData) {
      if (row[0] == newReference) { // Assuming the reference is in the first column
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("L\'article existe déjà !")),
        );
        return; // Exit the function without adding the row
      }
    }

    // Append the new row to the existing data
    csvData.add(newRow);
    final csv = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csv); // Overwrite the file with new data
  } else {
    // If the file doesn't exist, create it and write the header + data
    List<List<dynamic>> csvData = [
      ['Ref', 'Des', 'PU'], // Header
      newRow,
    ];
    final csv = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csv);
  }

  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Les données ont été enregistrées avec succès !")),
  );

  // Clear the text fields
  referenceController.clear();
  designationController.clear();
  priceController.clear();
  
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double textFieldWidth = screenWidth * 0.5;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 210, 210), // Set gray background
      appBar: AppBar(
        title: const Text('Ajouter un Article'),
        backgroundColor: const Color.fromARGB(255, 255, 89, 0),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Adjust padding to your preference
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Entrez les détails de l'article",
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 41, 41, 41),
                  ),
                ),
                const SizedBox(height: 25),

                // Référence
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

                // Désignation
                Container(
                  width: textFieldWidth,
                  child: TextField(
                    controller: designationController,
                    decoration: const InputDecoration(
                      labelText: 'Désignation de l\'article',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Prix
                Container(
                  width: textFieldWidth,
                  child: TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix Unitaire Hors Taxe (TND)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 20),

                
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: saveToCsv,
                  child: const Text('Ajouter'),
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
