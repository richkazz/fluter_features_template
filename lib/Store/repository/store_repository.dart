import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class StoreRepository {
  final Dio _client = Dio(BaseOptions(
    baseUrl: 'https://fakestoreapi.com/products',
  ));

  Future<List<Product>> getProducts() async {
    //await fetchData();
    final response = await _client.get('');
    if (kDebugMode) {
      print(response.data);
    }
    return (response.data as List)
        .map((json) => Product(
              id: json['id'],
              title: json['title'],
              image: json['image'],
            ))
        .toList();
  }

}
