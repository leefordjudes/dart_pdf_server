import 'dart:io';
import 'dart:convert';

// import 'package:dart_pdf_server/dart_pdf_server.dart' as server;
import 'package:dart_pdf_server/pdf.dart' as server;
import 'package:args/args.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('template', abbr: 't')
    ..addOption('data', abbr: 'd');
  final args = parser.parse(arguments);
  final b64template = args.option('template') ?? '';
  final data = args.option('data') ?? '';
  List<int> b64bytes = base64.decode(b64template);
  String template = utf8.decode(b64bytes);

  final pdfBytes = await server.generatePdf(template, data);
  print('dart len: ${pdfBytes.length}');
  // String base64String = base64.encode(pdfBytes);
  // stdout.writeAll([base64String]);
  // stdout.writeAll(pdfBytes);
  stdout.add(pdfBytes);
  await stdout.flush();

  // List<int> bytes = utf8.encode(data);
  // String out = utf8.decode(bytes);
  // print(out);
  // stdout.writeAll(pdfBytes);
  // return bytes;
}

/*
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('template', abbr: 't')
    ..addOption('data', abbr: 'd');
  final args = parser.parse(arguments);
  final b64template = args.option('template') ?? '';
  final data = args.option('data') ?? '';
  // final out = 'template: $template, data: $data';

  // List<int> bytes = out.runes.toList();
  // List<int> bytes = out.codeUnits;
  // List<int> bytes = utf8.encode(out);
  // String str = utf8.decode(bytes);
  // print(str);
  // stdout.writeAll(bytes);
  // print('Hello world: ${dart_pdf_server.calculate()}!');
  List<int> b64bytes = base64.decode(b64template);
  String template = utf8.decode(b64bytes);
  final pdfBytes = await server.generatePdf(template, data);
  // final file = File('output.pdf');
  // await file.writeAsBytes(pdfBytes);
  // return pdfBytes;
  String base64String = base64.encode(pdfBytes);
  stdout.writeAll([base64String]);
}

*/