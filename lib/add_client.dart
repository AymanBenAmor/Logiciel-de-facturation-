import 'package:flutter/material.dart';
import 'dart:io'; // For File operations
import 'package:path_provider/path_provider.dart'; // For getting app directory
import 'package:csv/csv.dart'; // For CSV file handling

class AddClientPage extends StatefulWidget {
  const AddClientPage({super.key});

  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  // Controllers for TextFields
  final TextEditingController codeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController mfController = TextEditingController();
 

  // Function to get the app's documents directory
  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDirectory = Directory('${directory.path}/AchrafApp/clients');

    if (!await pdfDirectory.exists()) {
      await pdfDirectory.create(recursive: true);
    }

    return "${pdfDirectory.path}/client.csv"; // CSV file path
  }

  // Function to validate inputs
  bool validateInputs() {
    
  if (codeController.text.isEmpty ||
    nameController.text.isEmpty ||
      adresseController.text.isEmpty ||
      mfController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires !")),
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
  final newcode = codeController.text.toUpperCase();
  final newRow = [
    newcode,
    nameController.text,
    adresseController.text,
    mfController.text,
    
  ];

  if(validateInputs()){

  
  // Check if the file exists
  if (await file.exists()) {
    // If the file exists, read the existing data
    final existingData = await file.readAsString();
    List<List<dynamic>> csvData = const CsvToListConverter().convert(existingData);

    // Check if the reference already exists
    for (var row in csvData) {
      if (row[0].toString() == newcode) {
      

         // Assuming the reference is in the first column
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Le code client existe déjà !")),
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
      ['code','nom', 'addresse', 'mf'], // Header
      newRow,
    ];
    final csv = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csv);
  }

  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Les données ont été enregistrées avec succès !")),
  );

  }
  // Clear the text fields
  codeController.clear();
  nameController.clear();
  adresseController.clear();
  mfController.clear();
  
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double textFieldWidth = screenWidth * 0.5;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 210, 210), // Set gray background
      appBar: AppBar(
        title: const Text('Ajouter un Client'),
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
                  "Entrez les détails du client",
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
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Code du client',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Référence
                Container(
                  width: textFieldWidth,
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du client',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Désignation
                Container(
                  width: textFieldWidth,
                  child: TextField(
                    controller: adresseController,
                    decoration: const InputDecoration(
                      labelText: 'Adresse du client',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Prix
                Container(
                  width: textFieldWidth,
                  child: TextField(
                    controller: mfController,
                    decoration: const InputDecoration(
                      labelText: 'MF du client',
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
