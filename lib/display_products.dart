import 'package:flutter/material.dart';
import 'dart:io'; // For File operations
import 'package:path_provider/path_provider.dart'; // For getting app directory
import 'package:csv/csv.dart'; // For CSV file handling

class ViewArticlesPage extends StatefulWidget {
  const ViewArticlesPage({super.key});

  @override
  State<ViewArticlesPage> createState() => _ViewArticlesPageState();
}

class _ViewArticlesPageState extends State<ViewArticlesPage> {
  List<List<dynamic>> csvData = []; // List to store CSV data

  // Function to get the app's documents directory
  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    
    final pdfDirectory = Directory('${directory.path}/AchrafApp/Article');

    if (!await pdfDirectory.exists()) {
      await pdfDirectory.create(recursive: true);
    }
    return "${pdfDirectory.path}/articles.csv";
  }

  // Function to read the CSV file
  Future<void> loadCsvData() async {
    final filePath = await getFilePath();
    final file = File(filePath);

    if (await file.exists()) {
      final existingData = await file.readAsString();
      setState(() {
        csvData = const CsvToListConverter().convert(existingData);
      });
    } else {
      setState(() {
        csvData = []; // Clear data if file doesn't exist
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadCsvData(); // Load data when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 210, 210), // Set gray background
      appBar: AppBar(
        title: const Text('Liste des Articles'),
        backgroundColor: const Color.fromARGB(255, 255, 89, 0),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: csvData.isEmpty
              ? const Text(
                  "Aucun article trouvé dans le fichier CSV !",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Enable vertical scrolling
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Référence', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Désignation', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Prix Unitaire', style: TextStyle(fontWeight: FontWeight.bold))),
                        
                      ],
                      rows: csvData
                          .skip(1) // Skip the header row
                          .map(
                            (row) => DataRow(
                              cells: [
                                DataCell(Text(row[0].toString())),
                                DataCell(Text(row[1].toString())),
                                DataCell(Text(row[2].toString())),
                                
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
