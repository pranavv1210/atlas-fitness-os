abstract interface class LocalCache<T> {
  Future<T?> read(String key);

  Future<void> write(String key, T value);

  Future<void> remove(String key);
}
