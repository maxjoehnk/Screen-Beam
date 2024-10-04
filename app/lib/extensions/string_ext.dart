extension StringExtensions on String {
  String toCapitalCase() {
    return splitMapJoin(RegExp(r"[( _)+]"), onNonMatch: (match) {
      if (match.isEmpty) {
        return "";
      }
      return match.substring(0, 1).toUpperCase() +
          match.substring(1).toLowerCase();
    }).replaceAll("_", " ");
  }
}
