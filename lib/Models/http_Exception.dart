class HtppException implements Exception {
  final String message;

  HtppException(this.message);

  @override
  String toString() {
    // TODO: implement toString
    // return super.toString();
    return message;
  }
}
