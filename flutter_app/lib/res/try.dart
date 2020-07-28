import 'dart:convert';

var data = [
  {"dx": 0.2, "dy": 0.3}
];

var str = json.encode(data);

var list = json.decode(str);

void main() {
  print(data);
  print(str);
  print(list);
}
