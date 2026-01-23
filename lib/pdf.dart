import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_pdf/dart_pdf.dart';

Future<Uint8List> generatePdf(String template, String data) async {
  final fontPath = 'assets/fonts';
  final courierPrimeRegularBytes = File('$fontPath/CourierPrime-Regular.ttf').readAsBytesSync();
  ByteData courierRegular = ByteData.sublistView(courierPrimeRegularBytes);
  final courierPrimeBoldBytes = File('$fontPath/CourierPrime-Bold.ttf').readAsBytesSync();
  ByteData courierBold = ByteData.sublistView(courierPrimeBoldBytes);

  PdfContext.instance.addFont('CourierPrime', 'Regular', courierRegular);
  PdfContext.instance.addFont('CourierPrime', 'Bold', courierBold);

  final yamlDoc = Document.fromYaml(template);
  final doc = await yamlDoc.save(PdfContext.instance, jsonDecode(data));
  return doc;
}
