// ignore: depend_on_referenced_packages
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

fetchdata(String url) async {
  http.Response response = await http.get(Uri.parse(url),
      headers: {'Connection': 'keep-alive', 'Keep-Alive': 'timeout=10'});
  return response.body;
}
