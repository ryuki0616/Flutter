void main() {
  print(test(10));
  print(test(null));
}

int test(int? a) {
  return a ?? 0;
}