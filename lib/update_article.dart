import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class UpdateArticlePage extends StatefulWidget {
  const UpdateArticlePage({super.key});

  @override
  State<UpdateArticlePage> createState() => _UpdateArticlePageState();
}

class _UpdateArticlePageState extends State<UpdateArticlePage> {
  List<List<dynamic>> csvData = [];
  int? selectedRowIndex;
  int? hoveredRowIndex;
  TextEditingController referenceController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  // Function to get the app's documents directory
  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final csvDirectory = Directory('${directory.path}/AchrafApp/Article');

    if (!await csvDirectory.exists()) {
      await csvDirectory.create(recursive: true);
    }
    return "${csvDirectory.path}/articles.csv";
  }

  // Function to load CSV data
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
        csvData = [];
      });
    }
  }

  // Function to save CSV data
  Future<void> saveCsvData() async {
    final filePath = await getFilePath();
    final file = File(filePath);

    final csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);
  }

  // Function to update the selected article
  void updateArticle() {
    if (selectedRowIndex != null) {
      setState(() {
        csvData[selectedRowIndex!] = [
          referenceController.text.toUpperCase(),
          designationController.text.toUpperCase(),
          priceController.text,
        ];
      });
      saveCsvData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article updated successfully!')),
      );
    }
    selectedRowIndex=null;
  }

  @override
  void initState() {
    super.initState();
    loadCsvData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 210, 210),
      appBar: AppBar(
        title: const Text('Modifier un Article'),
        backgroundColor: const Color.fromARGB(255, 255, 89, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40,bottom: 40, left: 200, right: 200),
        child: Column(
          children: [
            csvData.isEmpty
                ? const Text(
                    "Aucun article trouvé dans le fichier CSV !",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: csvData.length - 1,
                      itemBuilder: (context, index) {
                        final row = csvData[index + 1];
                        return MouseRegion(
                          onEnter: (_) {
                            setState(() {
                              hoveredRowIndex = index;
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              hoveredRowIndex = null;
                            });
                          },
                          child: Container(
                            color: hoveredRowIndex == index
                                ? const Color.fromARGB(47, 41, 75, 56)
                                : Colors.transparent,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(row[1].toString()), // Designation
                                  subtitle: Text("Prix: ${row[2]}"),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      setState(() {
                                        selectedRowIndex = index + 1;
                                        referenceController.text =
                                            row[0].toString();
                                        designationController.text =
                                            row[1].toString();
                                        priceController.text =
                                            row[2].toString();
                                      });
                                    },
                                  ),
                                ),
                                const Divider(
                                  thickness: 1,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            if (selectedRowIndex != null) ...[
              const SizedBox(height: 20),
              Container(
                color:
                    const Color.fromARGB(124, 56, 101, 75), // Background color for the bottom section
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: referenceController,
                      decoration: const InputDecoration(
                        labelText: 'Référence',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: designationController,
                      decoration: const InputDecoration(
                        labelText: 'Désignation',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix Unitaire',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateArticle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 89, 0),
                      ),
                      child: const Text(
                        'Enregistrer les modifications',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
