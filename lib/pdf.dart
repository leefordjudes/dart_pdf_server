import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dart_pdf/dart_pdf.dart' as dp;

import 'package:pdf/pdf.dart' as pd;
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generatePdf(String template, String data) async {
  final fontPath = './assets/fonts';
  final courierPrimeRegularBytes = File('$fontPath/CourierPrime-Regular.ttf').readAsBytesSync();
  ByteData courierRegular = ByteData.sublistView(courierPrimeRegularBytes);
  final courierPrimeBoldBytes = File('$fontPath/CourierPrime-Bold.ttf').readAsBytesSync();
  ByteData courierBold = ByteData.sublistView(courierPrimeBoldBytes);

  dp.PdfContext.instance.addFont('CourierPrime', 'Regular', courierRegular);
  dp.PdfContext.instance.addFont('CourierPrime', 'Bold', courierBold);

  final yamlDoc = dp.Document.fromYaml(template);
  final doc = await yamlDoc.save(dp.PdfContext.instance, jsonDecode(data));
  return doc;
}

double mm(double pt) {
  return pt * 72.0 / 25.4;
}

Future<Uint8List> generateLabel(String templateStr, String dataStr) async {
  final fontPath = './assets/fonts';
  final courierPrimeRegularBytes = File('$fontPath/CourierPrime-Regular.ttf').readAsBytesSync();
  ByteData courierRegular = ByteData.sublistView(courierPrimeRegularBytes);
  final courierPrimeBoldBytes = File('$fontPath/CourierPrime-Bold.ttf').readAsBytesSync();
  ByteData courierBold = ByteData.sublistView(courierPrimeBoldBytes);

  dp.PdfContext.instance.addFont('CourierPrime', 'Regular', courierRegular);
  dp.PdfContext.instance.addFont('CourierPrime', 'Bold', courierBold);

  final Map<String, dynamic> temp = Map<String, dynamic>.from(jsonDecode(templateStr));
  List<Map<String, dynamic>> data = List.from(jsonDecode(dataStr)).cast();

  final pdf = pw.Document();

  final double pageWidth = (temp['pageWidth'] as num).toDouble();
  final double pageHeight = (temp['pageHeight'] as num).toDouble();
  final double labelWidth = (temp['labelWidth'] as num).toDouble();
  final double labelHeight = (temp['labelHeight'] as num).toDouble();

  final int noOfColumns = temp['noOfColumns'] ?? 1;
  final int noOfRows = temp['noOfRows'] ?? 1;

  final List<dynamic> items = temp['items'];
  for (final chunk in data.slices(noOfRows * noOfColumns)) {
    final List<pw.Widget> children = [];

    for (final (rowIdx, chunk2) in chunk.slices(noOfColumns).indexed) {
      for (var colIdx = 0; colIdx < chunk2.length; colIdx++) {
        final rowData = chunk2[colIdx];

        for (final item in items) {
          final Map<String, dynamic> e = Map<String, dynamic>.from(item);

          final dp.PdfWidget widget = dp.PdfWidget.fromJson(e['child']);

          children.add(
            pw.Positioned(
              top: e['top'] != null ? mm((e['top'] as num).toDouble() + (rowIdx * labelHeight)) : null,
              right: e['right'] != null ? mm((e['right'] as num).toDouble()) : null,
              left: e['left'] != null ? mm((e['left'] as num).toDouble() + (colIdx * labelWidth)) : null,
              bottom: e['bottom'] != null ? mm((e['bottom'] as num).toDouble()) : null,
              child: widget.drawPdf(dp.PdfContext.instance, rowData),
            ),
          );
        }
      }
    }
    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(pageFormat: pd.PdfPageFormat(mm(pageWidth), mm(pageHeight))),
        build: (_) => pw.Stack(fit: pw.StackFit.expand, children: children),
      ),
    );
  }

  return await pdf.save();
}
