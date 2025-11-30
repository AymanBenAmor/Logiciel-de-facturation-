
import 'dart:typed_data';
import 'dart:io'; // For file operations


import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart'; // To get device directory for saving
import 'package:flutter/services.dart'; // For loading assets

class BL_Page extends StatefulWidget {
  const BL_Page({super.key});

  @override
  State<BL_Page> createState() => _BL_PageState();
}

class _BL_PageState extends State<BL_Page> {
  
  Uint8List? logoImage;
  

  // Create TextEditingController instances to control the text fields
  final TextEditingController _CodeclientController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _mfController = TextEditingController();

  List<TextEditingController> controllers = List.generate(20, (index) => TextEditingController());
  List<FocusNode> quantityFocusNodes = List.generate(20, (_) => FocusNode());
  List<FocusNode> RemiseFocusNodes = List.generate(20, (_) => FocusNode());


  List<String> foundReferences = [];
  List<String> Designation = [];
  List<String> PU = [];


  List<double> quantity = List.filled(20, 0.0);
  List<double> montant = List.filled(20, 0.0);
  List<double> Remise = List.filled(20, 0.0);



  List<String> temp=[];


  String montant_Total_HT = '0';
  

  int numero_BL = 1;



  // Variables to store input values
  String clientName = '';
  String adresse = '';
  String mf = '';

    //logo path
  String logo_path = 'data/flutter_assets/assets/logo.jpg';


  @override
  void initState() {
    super.initState();
    _loadLogoImage();
    get_numero_fact(); // Load the logo when the widget is initialized
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    _clientController.dispose();
    _adresseController.dispose();
    _mfController.dispose();
    super.dispose();
  }


  Future<void> addClientCsv(String filePath, List<List<dynamic>> rows) async {
  try {
    final file = File(filePath);

    // Check if the file exists
    if (!await file.exists()) {
      // If the file doesn't exist, create it and write a header + rows
      List<List<dynamic>> csvData = [
        
        ...rows, // Add provided rows
      ];
      final csv = const ListToCsvConverter().convert(csvData);
      await file.writeAsString(csv);
    } else {
      // If the file exists, append rows to it
      final existingData = await file.readAsString();
      List<List<dynamic>> csvData = const CsvToListConverter().convert(existingData);

      // Append new rows
      csvData.addAll(rows);
      final csv = const ListToCsvConverter().convert(csvData);
      await file.writeAsString(csv); // Overwrite the file with the updated data
    }

    print("Rows added successfully to $filePath");
  } catch (e) {
    print("Error while adding rows to CSV: $e");
  }
}


  Future<bool> checkCodeClientExists(String codeClient) async {
  // Get the file path of the CSV
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/AchrafApp/clients/client.csv';

  // Check if the file exists
  final file = File(filePath);
  if (!await file.exists()) {
    return false; // File doesn't exist, so the code client can't exist either
  }

  // Read the CSV file
  final csvData = await file.readAsString();
  List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

  // Check if the code client exists in the first column
  for (var row in rows.skip(1)) { // Skip the header row
    if (row[0].toString() == codeClient) {
      setState(() {
        clientName = row[1].toString();
        adresse = row[2].toString();
        mf = row[3].toString();


      });
      return true; // Found the code client
    }
  }

  return false; // Not found
}


  // Function to generate a column with a given number of lines
pw.Column generateTextColumn_string( List<String> list) {
  List<pw.Widget> texts = [];
  
  // Create 'numberOfLines' Text widgets dynamically
  for (int i = 0; i < list.length; i++) {
    texts.add(pw.Text(list[i], style: pw.TextStyle(fontSize: 8)));
    texts.add(pw.SizedBox(height: 6));
  }
  
  // Return the Column containing the Text widgets
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: texts,
  );
}

pw.Column generateTextColumn_remise() {
  List<pw.Widget> texts = [];
  
  // Create 'numberOfLines' Text widgets dynamically
  for (int i = 0; i < foundReferences.length; i++) {
    if(Remise[i] == Remise[i].floor()){
      texts.add(pw.Text(Remise[i].toInt().toString()+"%", style: pw.TextStyle(fontSize: 8)));
    texts.add(pw.SizedBox(height: 6));
    }else{
      texts.add(pw.Text(Remise[i].toString()+"%", style: pw.TextStyle(fontSize: 8)));
    texts.add(pw.SizedBox(height: 6));
    }
    
  }
  
  // Return the Column containing the Text widgets
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: texts,
  );
}

pw.Column generateTextColumn_double(List<double> list) {
  List<pw.Widget> texts = [];

  // Create 'numberOfLines' Text widgets dynamically
  for (int i = 0; i < list.length; i++) {
    if (list[i] != 0) {
      texts.add(pw.Text(list[i].toStringAsFixed(3), style: pw.TextStyle(fontSize: 8)));

      texts.add(pw.SizedBox(height: 6));
    }
  }

  // Return the Column containing the Text widgets
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: texts,
  );
}

pw.Column generateTextColumn_double_quantity(List<double> list) {
  List<pw.Widget> texts = [];

  // Create 'numberOfLines' Text widgets dynamically
  for (int i = 0; i < list.length; i++) {
    if (list[i] != 0) {
      // Check if list[i] has no digits after the decimal point
      if (list[i] == list[i].floor()) {
        texts.add(pw.Text(list[i].toInt().toString(), style: pw.TextStyle(fontSize: 8)));
      } else {
        texts.add(pw.Text(list[i].toString(), style: pw.TextStyle(fontSize: 8)));
      }
      texts.add(pw.SizedBox(height: 6));
    }
  }

  // Return the Column containing the Text widgets
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: texts,
  );
}

pw.Column generateTextColumn(String text) {
  List<pw.Widget> texts = [];
  
  // Create 'numberOfLines' Text widgets dynamically
  for (int i = 0; i < foundReferences.length; i++) {
    texts.add(pw.Text(text, style: pw.TextStyle(fontSize: 8)));
    texts.add(pw.SizedBox(height: 6));
  }
  
  // Return the Column containing the Text widgets
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: texts,
  );
}


double calculateTotalHT() {
  double result = 0;
  


  for (int i = 0; i < PU.length; i++) {
    double puValue = double.tryParse(PU[i]) ?? 0.0; // Parse PU as a double or default to 0.0
    double quantityValue = quantity[i] ;      // Use quantity[i] or default to 0.0

    result += quantityValue * puValue; // Add the product to the result
  }

  return result;

}

double calculateRemise() {
  double result = 0;
  for (int i = 0; i < PU.length; i++) {
    double puValue = double.tryParse(PU[i]) ?? 0.0; // Parse PU as a double or default to 0.0
    double quantityValue = quantity[i] ;
    
 

    result += quantityValue * puValue * Remise[i] / 100; // Add the product to the result
  }

  return result;

}

double TotalHTVA(){
  return(calculateTotalHT()-calculateRemise());
}


double TVA(){
  return(TotalHTVA() * 0.19);
}



double NetaPayer(){
  return(TotalHTVA() + TVA());
}

String calculateMontant(int index) {
  // Parse PU[index] to double safely
  double puValue = double.tryParse(PU[index]) ?? 0.0;
  

  // Ensure quantity[index] is not null (if it's nullable)
  double quantityValue = quantity[index] ;

  // Calculate the result, handling possible null values
  double result = puValue * quantityValue;

  // Apply the remise (discount) if it's valid
  result = result - (result * Remise[index] / 100);

  montant[index] = result;

  // Return the result as a string
  return result.toStringAsFixed(3); // Round to 2 decimal places for better formatting
}

String convertirEnTexteTnd(double montant) {
  if (montant == 0) return "zéro dinars";

  final List<String> unites = [
    "", "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf"
  ];
  final List<String> dizaines = [
    "", "", "vingt", "trente", "quarante", "cinquante",
    "soixante", "soixante-dix", "quatre-vingt", "quatre-vingt-dix"
  ];
  final List<String> ados = [
    "dix", "onze", "douze", "treize", "quatorze",
    "quinze", "seize", "dix-sept", "dix-huit", "dix-neuf"
  ];

  // Fonction pour convertir les nombres inférieurs à 1000
  String convertirCentaines(int n) {
    if (n < 0 || n > 999) {
      throw ArgumentError("Le nombre doit être compris entre 0 et 999 : $n");
    }

    String resultat = "";
    if (n >= 100) {
      resultat += "${unites[n ~/ 100]} cent ";
      if (n % 100 == 0 && n ~/ 100 > 1) resultat += "s"; // Pluriel pour les centaines
      n %= 100;
    }
    if (n >= 20) {
      resultat += "${dizaines[n ~/ 10]} ";
      n %= 10;
    } else if (n >= 10) {
      resultat += "${ados[n - 10]} ";
      n = 0;
    }
    if (n > 0) {
      resultat += "${unites[n]} ";
    }
    return resultat.trim();
  }

  // Fonction pour convertir les nombres en groupes (milliers, millions, etc.)
  String convertirGrandNombre(int n) {
    if (n == 0) return "";

    List<String> groupes = ["", "mille", "million", "milliard"];
    String resultat = "";

    int i = 0;
    while (n > 0) {
      int groupe = n % 1000;
      if (groupe > 0) {
        String prefixe = convertirCentaines(groupe);
        if (i == 1 && groupe == 1) {
          // Cas spécial pour "mille" (pas "un mille")
          resultat = "${groupes[i]} $resultat";
        } else {
          resultat = "$prefixe ${groupes[i]} $resultat";
        }
      }
      n ~/= 1000;
      i++;
    }

    return resultat.trim();
  }

  // Séparer les dinars et les millimes
  int dinars = montant.toInt(); // Partie entière
  int millimes = ((montant - dinars) * 1000).round();

  // Conversion des dinars
  String texteDinars = "";
  if (dinars > 0) {
    texteDinars = convertirGrandNombre(dinars) + (dinars == 1 ? " dinar" : " dinars");
  }

  // Conversion des millimes
  String texteMillimes = "";
  if (millimes > 0) {
    texteMillimes = convertirCentaines(millimes) + " millimes";
  }

  // Combinaison des résultats
  if (dinars > 0 && millimes > 0) {
    return "$texteDinars et $texteMillimes";
  } else if (dinars > 0) {
    return texteDinars;
  } else {
    return texteMillimes;
  }
}





  // Method to load the logo image from assets
  Future<void> _loadLogoImage() async {
    final byteData = await rootBundle.load('assets/logo.png'); // Replace with your logo path
    setState(() {
      logoImage = byteData.buffer.asUint8List();
    });
  }



  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDirectory = Directory('${directory.path}/AchrafApp/Article');

    if (!await pdfDirectory.exists()) {
      await pdfDirectory.create(recursive: true);
    }

    return "${pdfDirectory.path}/articles.csv"; // CSV file path
  }

  Future<bool> isReferenceInCsv(String reference) async {
  
  final pathOfTheFile = await getFilePath();  // Replace with your actual CSV file path

  File file = File(pathOfTheFile);
  if (await file.exists()) {
    String fileContents = await file.readAsString();
    List<List<dynamic>> rows = const CsvToListConverter().convert(fileContents);

    for (var row in rows) {
      if (row[0] == reference.toUpperCase()) {
        
        setState(() {
          temp.add(row[0]);
          temp.add(row[1]);
          temp.add(row[2].toString());
          

        });
        
        

        return true;
      }
    }
  }
  return false;
}


Future<String> getFilePath_numero() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDirectory = Directory('${directory.path}/AchrafApp/BL/${DateTime.now().year.toString()}');

    if (!await pdfDirectory.exists()) {
      await pdfDirectory.create(recursive: true);
    }

    return "${pdfDirectory.path}/numero_BL.csv"; // CSV file path
  }

Future<dynamic> get_numero_fact() async {
  final pathOfTheFile = await getFilePath_numero();  // Replace with your actual CSV file path

  File file = File(pathOfTheFile);

  // Check if the file exists
  if (!await file.exists()) {
    // Create the file and write a default header or initial data
    List<List<dynamic>> initialData = [
      [1], // Example header row
    ];
    String csvData = const ListToCsvConverter().convert(initialData);
    await file.writeAsString(csvData);
    return initialData;
  }

  // Read and parse the existing CSV file
  String content = await file.readAsString();
  List<List<dynamic>> rows = const CsvToListConverter().convert(content);
  
  setState(() {
    numero_BL = rows[0][0];
  });
  
  print(numero_BL);

}

Future<void> increment_num_fact() async {

  final pathOfTheFile = await getFilePath_numero();  // Replace with your actual CSV file path

  File file = File(pathOfTheFile);

  String content = await file.readAsString();
  List<List<dynamic>> rows = const CsvToListConverter().convert(content);
  
  setState(() {
    numero_BL = rows[0][0];
  });
  

  rows[0][0] = numero_BL + 1;
  String updatedCsvData = const ListToCsvConverter().convert(rows);
  await file.writeAsString(updatedCsvData);
}


Future<void> generatePdf(String clientName, String address, String mfNumber) async {
  final pdf = pw.Document();
  increment_num_fact();



  // Define the PDF content
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginBottom: 0,
        marginLeft: 10,
        marginRight: 10,
        marginTop: 15,
      ),
      build: (context) {
       
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header Section
            // Company Info and Logo Section
pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.center,
  children: [
    // Logo Container
    pw.Container(
      height: 120,
      width: 120,
      child: pw.Image(
        pw.MemoryImage(
          File(logo_path).readAsBytesSync(), // Replace with your logo
        ),
        fit: pw.BoxFit.cover,
      ),
    ),
    pw.SizedBox(width: 60),
    // Company Info Container
    pw.Container(
      // Constrain the width for proper text wrapping
      width: 350,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            "MNIFEG",
            style: pw.TextStyle(
              fontSize: 55,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 25,
            ),
          ),
          pw.Text(
            "Societé Achraf Mnif Equipements Générales",
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              wordSpacing: 2.5,
            ),
          ),
          pw.SizedBox(height: 5),
          // Address Text with Wrapping
          pw.Text(
            "ADRESSE: AV LIBERTE IMM BECHR 2 SFAX, Sfax Magreb \nArabe, Sfax Médina, Sfax, 3049",
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              height: 2,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 3),
          // Email Text
          pw.Text(
            "E-mail: contact.mnifeg@gmail.com",
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            "Vente Gros Produits Divers",
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            "MF: 1901987A/AM/000\tN°RNE: 1901987A",
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          
          // Phone Text
          pw.Text(
            "Tél: +216 22 922 811",
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  ],
),



           
            pw.SizedBox(height: 15),
             pw.Text(
      "BON DE LIVRAISON",
      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
    ),
    pw.SizedBox(width: 20),

            // Invoice Title
           pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  children: [
    // Invoice Info Section with fixed width of 150
    pw.Container(
      padding: const pw.EdgeInsets.all(5),
      width: 150,  // Fixed width for the first container
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Numero", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text("Date", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Divider(height: 2, color: PdfColors.black),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "BL SF $numero_BL/${DateTime.now().year.toString().substring(2)}", // Extract the last 2 digits of the current year
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                DateFormat('dd/MM/yyyy').format(DateTime.now()), // Automatically prints the current date
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    ),
    
    pw.SizedBox(width: 50), // Space between the two containers

    // Client Details Section (takes remaining space)
    pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black, width: 0.8),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text(
                  "Client: ",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    clientName,
                    style: pw.TextStyle(fontSize: 10),
                    overflow: pw.TextOverflow.clip,  // Ensures it wraps
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              children: [
                pw.Text(
                  "Adresse: ",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    address,
                    style: pw.TextStyle(fontSize: 10),
                    overflow: pw.TextOverflow.clip,  // Ensures it wraps
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              children: [
                pw.Text(
                  "MF: ",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    mfNumber,
                    style: pw.TextStyle(fontSize: 10),
                    overflow: pw.TextOverflow.clip,  // Ensures it wraps
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ],
),

pw.SizedBox(height: 15), // Space between the client details and the table

    // Table Section
   pw.Table(
  border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
  columnWidths: {
    0: pw.FixedColumnWidth(65), // Width for Column 1
    1: pw.FixedColumnWidth(190), // Width for Column 2
    2: pw.FixedColumnWidth(35), // Width for Column 3
    3: pw.FixedColumnWidth(35), // Width for Column 4
    4: pw.FixedColumnWidth(40), // Width for Column 5
    
    5: pw.FixedColumnWidth(25), // Width for Column 7
    6: pw.FixedColumnWidth(50), // Width for Column 8
  },
  children: [
    // First row (headers)
    pw.TableRow(
  children: [
    pw.Container(
      padding: pw.EdgeInsets.all(5),
      color: PdfColors.grey300,
      child: pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text('Réference', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
      ),
    ),
    pw.Container(
      padding: pw.EdgeInsets.all(5),
      color: PdfColors.grey300,

      child: pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text('Désignation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
      ),
    ),
    pw.Container(
      padding: pw.EdgeInsets.all(5),
      color: PdfColors.grey300,

      child: pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text('Qté', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
      ),
    ),
    pw.Container(
      padding: pw.EdgeInsets.all(5),
      color: PdfColors.grey300,

      child: pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text('P.U.H.T', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
      ),
    ),
    pw.Container(
      padding: pw.EdgeInsets.all(5),
      color: PdfColors.grey300,

      child: pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text('Remise', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
      ),
    ),
    
    pw.Container(
      padding: pw.EdgeInsets.all(5),
      color: PdfColors.grey300,

      child: pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text('TVA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
      ),
    ),
    pw.Container(
      padding: pw.EdgeInsets.all(5),
      color: PdfColors.grey300,

      child: pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text('Montant HT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
      ),
    ),
  ],
),
// Second row with height of 300 and reduced font size
pw.TableRow(
  children: [
    pw.Container(
      height: 310,
      alignment: pw.Alignment.center,
      padding: pw.EdgeInsets.all(5),
      child: generateTextColumn_string(foundReferences),
    ),
    pw.Container(
      height: 310,
      padding: pw.EdgeInsets.all(5),
      child: generateTextColumn_string(Designation),

    ),
    pw.Container(
      height: 310,
      alignment: pw.Alignment.center,
      padding: pw.EdgeInsets.all(5),
      child: generateTextColumn_double_quantity(quantity),

    ),
    pw.Container(
      height: 310,
      padding: pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: generateTextColumn_string(PU),

    ),
    pw.Container(
      height: 310,
      padding: pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: generateTextColumn_remise(),

    ),
    
    pw.Container(
      height: 310,
      alignment: pw.Alignment.center,
      padding: pw.EdgeInsets.all(5),
      child: generateTextColumn('19%'),
    ),
    pw.Container(
      height: 310,
      alignment: pw.Alignment.center,
      padding: pw.EdgeInsets.all(5),
      child: generateTextColumn_double(montant),

    ),
  ],
),

  ],
),

 pw.SizedBox(height: 20), // Add some space between tables
    // Row containing two tables
    pw.Row(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    // First table (3 rows, 4 columns)
    pw.Expanded(
      flex: 1,
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black, width: 1),
        children: [
          pw.TableRow(
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(2), // Padding in each cell
                child: pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text("TAXE", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(2),
                child: pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text("BASE", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(2),
                child: pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text("TAUX", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(2),
                child: pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text("MONTANT", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ),
              ),
            ],
          ),
           // 2 rows
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(2),
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    child: pw.Text("TVA", style: pw.TextStyle(fontSize: 8)),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(2),
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    child: pw.Text(TotalHTVA().toStringAsFixed(3), style: pw.TextStyle(fontSize: 8)),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(2),
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    child: pw.Text(19.toStringAsFixed(3), style: pw.TextStyle(fontSize: 8)),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(2),
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    child: pw.Text(TVA().toStringAsFixed(3), style: pw.TextStyle(fontSize: 8)),
                  ),
                ),
              ],
            ),

             


        ],
      ),
    ),
    pw.SizedBox(width: 120), // Space between the tables
    // Second table (1 row, 2 columns)
    pw.Expanded(
      
      flex: 1,
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black, width: 1),
        
        children: [
  pw.TableRow(
    children: [
      pw.Padding(
        padding: pw.EdgeInsets.all(4),
        child: pw.Align(
          alignment: pw.Alignment.centerLeft, // Center the text
          child: pw.Text("TOTAL HT", style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.all(4),
        child: pw.Align(
          alignment: pw.Alignment.centerRight, // Center the text
          child: pw.Text(calculateTotalHT().toStringAsFixed(3), style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
        ),
      ),
    ],
  ),
  pw.TableRow(
    children: [
      pw.Padding(
        padding: pw.EdgeInsets.all(4),
        child: pw.Align(
          alignment: pw.Alignment.centerLeft, // Center the text
          child: pw.Text("REMISE", style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.all(4),
        child: pw.Align(
          alignment: pw.Alignment.centerRight, // Center the text
          child: pw.Text(calculateRemise().toStringAsFixed(3), style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
        ),
      ),
    ],
  ),
  

  pw.TableRow(
    children: [
      pw.Padding(
        padding: pw.EdgeInsets.all(4),
        child: pw.Align(
          alignment: pw.Alignment.centerLeft, // Center the text
          child: pw.Text("Total H.TVA", style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.all(4),
        child: pw.Align(
          alignment: pw.Alignment.centerRight, // Center the text
          child: pw.Text(TotalHTVA().toStringAsFixed(3), style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
        ),
      ),
    ],
  ),
  pw.TableRow(
    children: [
      pw.Padding(
        padding: pw.EdgeInsets.all(4),
        child: pw.Align(
          alignment: pw.Alignment.centerLeft, // Center the text
          child: pw.Text("TVA", style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.all(4),
        child: pw.Align(
          alignment: pw.Alignment.centerRight, // Center the text
          child: pw.Text(TVA().toStringAsFixed(3), style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
        ),
      ),
    ],
  ),
  
  pw.TableRow(
    children: [
      pw.Padding(
        padding: pw.EdgeInsets.all(4),
        child: pw.Align(
          alignment: pw.Alignment.centerLeft, // Center the text
          child: pw.Text("Net à payer", style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.all(4),
        child: pw.Align(
          alignment: pw.Alignment.centerRight, // Center the text
          child: pw.Text(NetaPayer().toStringAsFixed(3), style: pw.TextStyle(fontSize: 8,fontWeight: pw.FontWeight.bold)),
        ),
      ),
    ],
  ),
],
      ),
    ),
    


  ],
  
),
pw.SizedBox(height: 30),
pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Text(
          "Arreter le présent bon de livraison à la somme de :\n",
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),

    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Text(
          convertirEnTexteTnd(NetaPayer()),
          style: pw.TextStyle(
            fontSize: 8,
            //fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),

pw.SizedBox(height: 5),

pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(
         
          "Page 1 sur 1",
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),



          ],
        );
      },
    ),
  );

  // Get directory to save PDF file
  final directory = await getApplicationDocumentsDirectory();
  final pdfDirectory = Directory('${directory.path}/AchrafApp/BL/${DateTime.now().year.toString()}/${DateTime.now().month.toString()}/pdf');



  // Check if the directory exists, create it if not
  if (!await pdfDirectory.exists()) {
    await pdfDirectory.create(recursive: true);
  }

 

  // Set the file path for the PDF
  final filePath = '${pdfDirectory.path}/BL N° $numero_BL.pdf';

  try {
  final pdfBytes = await pdf.save();
  final file = File(filePath);

  await file.writeAsBytes(pdfBytes); // Save the PDF

   ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('BL saved in: $filePath')),
  );

} catch (e) {
 
  // Optionally, show an alert or Snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error saving BL: $e')),
  );
}

  String csvClientPath = '${directory.path}/AchrafApp/BL/${DateTime.now().year.toString()}/${DateTime.now().month.toString()}/$clientName.csv';
  List<List<dynamic>> rows = [];

  rows.add(['','BL N $numero_BL/${DateTime.now().year.toString().substring(2)}  ${DateFormat('dd/MM/yyyy').format(DateTime.now())}','','','','','']);

// Populate the rows with data
for (int i = 0; i < foundReferences.length; i++) {
  if(quantity[i] == quantity[i].floor()){

    rows.add([
    foundReferences[i], // First column
    Designation[i],     // Second column
    quantity[i].toInt(),        // Third column
    PU[i],
    Remise[i],
    "19",   
    montant[i].toStringAsFixed(3),           // Fourth column
  ]);

  }else{
    rows.add([
    foundReferences[i], // First column
    Designation[i],     // Second column
    quantity[i],        // Third column
    PU[i],
    Remise[i],
    "19",   
    montant[i].toStringAsFixed(3),           // Fourth column
  ]);
  }
  
}
  addClientCsv(csvClientPath,rows);
  // Print the saved PDF
  for(int i=0;i<2;i++){
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
  }
Navigator.pop(context);
  
}


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: const Text("BON DE LIVRAISON"),
        backgroundColor: const Color.fromARGB(255, 255, 89, 0),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed:() async{
              // Generate and save the PDF
              generatePdf(clientName, adresse, mf);
              

            }
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
          width: 595.0, // A4 width in points (8.27 inches)
          height: 841.0, // A4 height in points (11.69 inches)
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black), // Optional: border to visualize A4 page size
            color: Colors.white,
          ),
          padding: const EdgeInsets.only(top: 20, left: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row to align logo and company details
              Row(
  children: [
    // Load and display logo from assets
    Image.asset(
      'assets/logo.jpg', // Replace with the actual path to your logo image
      width: 120, // Adjust logo size
      height: 120,
    ),
    SizedBox(width: 15),
    Expanded(
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(0, 0, 0, 0),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "MNIFEG",
                style: TextStyle(
                  fontSize: 65,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 25,
                  height: 0.8,
                ),
              ),
              Text(
                "Societé Achraf Mnif Equipements Générales",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  wordSpacing: 4,
                ),
              ),
              
              SizedBox(height: 3,),
              Text(
                "ADRESSE: AV LIBERTE IMM BECHR 2 SFAX, Sfax Magreb \nArabe, Sfax Médina, Sfax, 3049",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
                textAlign: TextAlign.center, // Center-align the text
                softWrap: true, // Enable wrapping
                overflow: TextOverflow.visible, // Ensure overflow is handled
              ),
              
              Text(
                "E-mail: contact.mnifeg@gmail.com",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Vente Gros Produits Divers",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  wordSpacing: 4,
                ),
              ),
              Text(
                "MF: 1901987A/AM/000\tN°RNE: 1901987A",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Tél: +216 22 922 811",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ],
),

              SizedBox(height: 15),

              // Add a new Row below this one with the table and the rectangular box
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Left side: Small table (3 lines, 2 columns)
                  Container(
                    width: 200, // Set width for the left side table
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add "facture" text above the table
                        Text(
                          "BON DE LIVRAISON",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 0.5,
                          ),
                        ),
                        SizedBox(height: 10), // Optional space between "facture" and the table
                        // Container with border radius around the table
                        Container(
                          child: Table(
                            border: TableBorder.all(
                              borderRadius: BorderRadius.circular(5),
                              // Optional: border radius for each cell
                            ),
                            columnWidths: {
                              0: FlexColumnWidth(0.7), // Adjust width of the first column
                              1: FlexColumnWidth(0.5), // Adjust width of the second column
                            },
                            children: [
                              // Second row with "Numero" and "Date"
                              TableRow(
                                children: [
                                  Text(
                                    "Numero",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "Date",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              // Third row with actual data values
                              TableRow(
                                children: [
                                  Text(
                                    "BL SF $numero_BL/${DateTime.now().year.toString().substring(2)}", // Extract the last 2 digits of the current year
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(DateTime.now()), // Automatically prints the current date
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 30),

                  // Right side: Rectangular box
                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client Row
                       Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    Text(
      "Code Client: ",
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    ),
    SizedBox(width: 5), // Add space between label and textfield
    Expanded(
      child: Container(
        height: 25, // Adjust the height of the TextField's container
        child: TextField(
          controller: _CodeclientController,
          style: TextStyle(fontSize: 10),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 4), // Adjust vertical padding if necessary
          ),
          onSubmitted: (value) async {
            // Call the function to check the Code Client
            final exists = await checkCodeClientExists(value);
            if (!exists) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Le client n\'existe pas!")),
              );
              _CodeclientController.clear();
            }
          },
        ),
      ),
    ),
  ],
),

                        SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Client:",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10), // Add space between label and textfield

                            Expanded(
                              child: Container(
                                
                                child: Text(
                                  clientName,
                                  style: TextStyle(fontSize: 11,),
                                )
                              ),
                            ),
                            
                          ],
                        ),
                        SizedBox(height: 10), // Add space between rows
                        // Adresse Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Adresse: ",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10), // Add space between label and textfield
                            Expanded(
                              child: Container(
                               
                                child: Text(
                                  adresse,
                                  style: TextStyle(fontSize: 11),
                                )
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10), // Add space between rows
                        // MF Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "MF: ",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                
                                child: Text(
                                  mf,
                                  style: TextStyle(fontSize: 11,),
                                )
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),
              Table(
  border: TableBorder.all(color: Colors.black, width: 0.5),
  columnWidths: {
    0: FixedColumnWidth(80), // ref
    1: FixedColumnWidth(240), //des
    2: FixedColumnWidth(35), // qte
    3: FixedColumnWidth(45), // PUHT
    4: FixedColumnWidth(40), // Remise
    
    5: FixedColumnWidth(30), // TVA
    6: FixedColumnWidth(70), // Montant HT
  },
  children: [
    // First row (headers)
    TableRow(
  children: [
    Container(
      padding: EdgeInsets.all(5),
      color: Colors.grey,
      child: Align(
        alignment: Alignment.center,
        child: Text('Réference', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8)),
      ),
    ),
    Container(
      padding: EdgeInsets.all(5),
      color: Colors.grey,

      child: Align(
        alignment: Alignment.center,
        child: Text('Désignation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8)),
      ),
    ),
    Container(
      padding: EdgeInsets.all(5),
      color: Colors.grey,

      child: Align(
        alignment: Alignment.center,
        child: Text('Qté', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8)),
      ),
    ),
    Container(
      padding: EdgeInsets.all(5),
      color: Colors.grey,

      child: Align(
        alignment: Alignment.center,
        child: Text('P.U.H.T', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8)),
      ),
    ),
    Container(
      padding: EdgeInsets.all(5),
      color: Colors.grey,

      child: Align(
        alignment: Alignment.center,
        child: Text('Remise', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8)),
      ),
    ),
    
    Container(
      padding: EdgeInsets.all(5),
      color: Colors.grey,

      child: Align(
        alignment: Alignment.center,
        child: Text('TVA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8)),
      ),
    ),
    Container(
      padding: EdgeInsets.all(5),
      color: Colors.grey,

      child: Align(
        alignment: Alignment.center,
        child: Text('Montant HT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8)),
      ),
    ),
  ],
),
// Second row with height of 300 and reduced font size
TableRow(
  children: [
// input for reference
Container(
  height: 405,
  padding: EdgeInsets.all(2),
  child: ListView.builder(
    itemCount: 20, // Create 20 TextFields
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2.0), // Add spacing between TextFields
        child: Container(
          height: 18, // Adjust the height of the TextField's container
          child: TextField(
            controller: controllers[index], // Set controller for each TextField
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(1), // Remove all padding to eliminate space between text and border
            ),
            style: TextStyle(fontSize: 10), // Adjust text size
            onSubmitted: (input) async {
              // Check if the input appears in the CSV file after submission
              bool found = await isReferenceInCsv(input.toUpperCase());
              if (found) {
                // Check if the reference is already in the list
                if (!foundReferences.contains(input.toUpperCase())) {
                  setState(() {
                    foundReferences.add(temp[temp.length - 3]);
                    Designation.add(temp[temp.length - 2]);
                    PU.add(temp[temp.length - 1]);
                  });
                  // Move focus to the corresponding quantity input
                  FocusScope.of(context).requestFocus(quantityFocusNodes[index]);
                } else {
                  controllers[index].clear();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Référence existe déjà dans la facture.'),
                  ));
                }
              } else {
                // Clear the TextField if reference is not found
                controllers[index].clear();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Référence invalide.'),
                ));
              }
            },
          ),
        ),
      );
    },
  ),
),



Container(
  height: 405,
  padding: EdgeInsets.all(5),
  child: ListView.builder(
    itemCount: Designation.length, // Use the length of the list
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text(
          Designation[index], // Display the designation at the current index
          style: TextStyle(fontSize: 9),
        ),
      );
    },
  ),
),



// Input for quantity
Container(
  height: 405,
  padding: EdgeInsets.all(2),
  child: ListView.builder(
    itemCount: 20, // Create 20 TextFields
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2.0), // Add spacing between TextFields
        child: Container(
          height: 18, // Adjust the height of the TextField's container
          child: TextField(
            focusNode: quantityFocusNodes[index], // Assign the corresponding focus node
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(1), // Remove all padding to eliminate space between text and border
            ),
            style: TextStyle(fontSize: 10), // Adjust text size
            keyboardType: TextInputType.number, // Show numeric keyboard
            onSubmitted: (input) {
              // Convert input to double and add to quantities list
              double? value = double.tryParse(input); // Safely parse the input
              if (value != null) {
                setState(() {
                  quantity[index] = value; // Update the quantity in the list
                });
                  FocusScope.of(context).requestFocus(RemiseFocusNodes[index]);

              } else {
                // Show a warning for invalid input
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Invalid quantity. Please enter a valid number.'),
                ));
              }
            },
          ),
        ),
      );
    },
  ),
),

  

  Container(
  height: 405,
  padding: EdgeInsets.all(5),
  child: ListView.builder(
    itemCount: PU.length, // Use the length of the list
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text(
          PU[index], // Display the designation at the current index
          style: TextStyle(fontSize: 9),
        ),
      );
    },
  ),
),

  // Input for Remise
Container(
  height: 405,
  padding: EdgeInsets.all(2),
  child: ListView.builder(
    itemCount: 20, // Create 20 TextFields
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2.0), // Add spacing between TextFields
        child: Container(
          height: 18, // Adjust the height of the TextField's container
          child: TextField(
            focusNode: RemiseFocusNodes[index], // Assign the corresponding focus node
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(1), // Remove all padding to eliminate space between text and border
            ),
            style: TextStyle(fontSize: 10), // Adjust text size
            keyboardType: TextInputType.number, // Show numeric keyboard
            onSubmitted: (input) {
              // Convert input to double and add to quantities list
              double? value = double.tryParse(input); // Safely parse the input
              if (value != null) {
                setState(() {
                  Remise[index] = value; // Update the quantity in the list
                });
              } else {
                setState(() {
                  Remise[index] = 0; // Update the quantity in the list
                });
                // Show a warning for invalid input
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Remise invalide.'),
                ));
              }
            },
          ),
        ),
      );
    },
  ),
), 
     Container(
  height: 405,
  padding: EdgeInsets.all(5),
  child: ListView.builder(
    itemCount: foundReferences.length, // Use the length of the list
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text(
          '19%', // Display the designation at the current index
          style: TextStyle(fontSize: 9),
        ),
      );
    },
  ),
),
   
   Container(
  height: 405,
  padding: EdgeInsets.all(5),
  child: ListView.builder(
    itemCount: foundReferences.length, // Use the length of the list
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text(
          calculateMontant(index), // Display the designation at the current index
          style: TextStyle(fontSize: 9),
        ),
      );
    },
  ),
),

  ],
),

  ],
),

              // Table for items (product name, quantity, price, total)
            ],
          ),
        ),
      ),
      ),
    );
  }


}