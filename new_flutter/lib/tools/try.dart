void main() {
  String str = "124@2135@11342@";
  String tmp = str.substring(0, str.indexOf("2135"));
  String tmp1 = str.substring(str.indexOf("2135")+5);
  String res = tmp + tmp1;
  print(tmp);
  print(tmp1);
  print(res);
}
