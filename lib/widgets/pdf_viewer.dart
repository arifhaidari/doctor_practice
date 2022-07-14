// import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../utils/utils.dart';

class PDFViewerPage extends StatefulWidget {
  final File file;

  const PDFViewerPage({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
//   final url =
//     'https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf';
// final file = await PDFMixin.loadNetwork(url);
// final pdfFile = await ImgPDFPrinting.generatePdfFromImage();
  late PDFViewController controller;
  int pages = 0;
  int indexPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final name = basename(widget.file.path);
    final text = '${indexPage + 1} of $pages';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style:
              TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Palette.blueAppBar,
        actions: pages >= 2
            ? [
                Center(child: Text(text)),
                IconButton(
                  icon: Icon(Icons.chevron_left, size: 32),
                  onPressed: () {
                    final page = indexPage == 0 ? pages : indexPage - 1;
                    controller.setPage(page);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, size: 32),
                  onPressed: () {
                    final page = indexPage == pages - 1 ? 0 : indexPage + 1;
                    controller.setPage(page);
                  },
                ),
              ]
            : null,
      ),
      body: PDFView(
        filePath: widget.file.path,
        // autoSpacing: false,
        // swipeHorizontal: true,
        // pageSnap: false,
        // pageFling: false,
        onRender: (pages) => setState(() => this.pages = pages!),
        onViewCreated: (controller) => setState(() => this.controller = controller),
        onPageChanged: (indexPage, _) => setState(() => this.indexPage = indexPage!),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Palette.blueAppBar,
        onPressed: () => printPdf(widget.file.path),
        // onPressed: () => printBottomSheet(context),
        child: Icon(Icons.print),
      ),
    );
  }

  void printBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Modal BottomSheet'),
              ElevatedButton(
                child: const Text('Close BottomSheet'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        );
      },
    );
  }

  void printPdf(doc) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }
}

class PDFMixin {
  static Future<File> loadAsset(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List();

    return _storeFile(path, bytes);
  }

  static Future<File> loadNetwork(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    return _storeFile(url, bytes);
  }

  static Future<File> _storeFile(String url, List<int> bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}

// All Action for pdf
// final path = 'assets/patient_file.pdf';
// final file = await PDFMixin.loadAsset(path);
//
// final url =
//     'https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf';
// final file = await PDFMixin.loadNetwork(url);
// final pdfFile = await ImgPDFPrinting.generatePdfFromImage();
// await Printing.sharePdf(
//     bytes: file.readAsBytesSync(),
//     filename: 'medical_record_$randomNum.pdf');
// await Printing.layoutPdf(
//   onLayout: (PdfPageFormat format) async {
//     return pdfFile as pw.Document;
//   },
// );
// // ImgPDFPrinting.openFile(pdfFile);
// Navigator.of(context).push(MaterialPageRoute(
//     builder: (context) => PDFViewerPage(file: pdfFile)));
