class Gallery{
  int id;
  String url;

  Gallery.fromJson(Map<String,dynamic> map):id = map['id'],url = map['path'];
}