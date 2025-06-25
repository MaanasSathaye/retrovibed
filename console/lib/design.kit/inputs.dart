void _notimplemented(String s) {
  return print(s);
}

void defaulttap() => _notimplemented("tap not implemented");

Future<T> defaulttapfn<T>(T v) {
  _notimplemented("tap not implemented");
  return Future.value(v);
}

Future<void> defaulttapv() => Future.sync(() => _notimplemented("tap not implemented"));