extension MapExtensions<K, V> on Map<K, V> {
  List<T> mapToList<T>(T Function(K, V) f) {
    return entries.map((e) => f(e.key, e.value)).toList();
  }
}
