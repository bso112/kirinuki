extension StringExt on String {
  String? toNullIfEmpty() {
    return isEmpty ? null : this;
  }
}
