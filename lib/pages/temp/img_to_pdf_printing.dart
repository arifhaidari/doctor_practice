// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart';
// import '../utils/utils.dart';

// class ImgPDFPrinting {
//   static Future<File> generatePdfFromImage() async {
//     print('inside the generateImage');
//     final pdf = Document();
//     List<Widget> myList = [];

//     for (int i = 0; i < assetPicList.length; i++) {
//       var temp = (await rootBundle.load(assetPicList[i])).buffer.asUint8List();
//       myList.add(Image(MemoryImage((temp))));
//     }

//     pdf.addPage(
//       MultiPage(
//         build: (context) => [
//           ...myList,
//         ],
//       ),
//     );

//     return savePdf(name: 'medical_record_$randomNum.pdf', pdf: pdf);
//   }

//   static Future<File> savePdf({
//     required String name,
//     required Document pdf,
//   }) async {
//     final bytes = await pdf.save();

//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/$name');

//     await file.writeAsBytes(bytes);

//     return file;
//   }
// }
