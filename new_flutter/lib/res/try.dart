import 'dart:convert';

var data = [
  {"dx": 0.2, "dy": 0.3}
];

var str = json.encode(data);

var list = json.decode(str);

List tmp = ["111"];

void add(List list) {
  list.add("123");
}

void main() {
  print(tmp);
  add(tmp);
  print(tmp);
}
