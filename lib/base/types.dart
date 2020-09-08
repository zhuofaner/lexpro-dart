class Tuple<T, U> {
  const Tuple(this.first, this.second);
  final T first;
  final U second;
}

class Tuple2<T, U, V> {
  const Tuple2(this.first, this.second, this.third);
  final T first;
  final U second;
  final V third;
}

class RegExpFlags {
  RegExpFlags({
    this.dotAll = false,
    this.unicode = false,
    this.multiline = false,
    this.caseSensitive: false,
  });

  final bool dotAll;
  final bool unicode;
  final bool multiline;
  final bool caseSensitive;
}
