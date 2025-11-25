// Esse arquivo só existe para o app não quebrar no Android/iOS/Windows
class ScriptElement {
  String src = '';
  String id = '';
  bool async = false;
  bool defer = false;
}

class Document {
  final head = HeadElement();
}

class HeadElement {
  void append(dynamic element) {}
}

final document = Document();