import 'package:dio/dio.dart';
import 'package:yandex_task/branch_model.dart';

class Api {
  final _dio = Dio(
    BaseOptions(),
  );

  Future<MaxWayBranch> main() async {
    final response = await _dio.get("https://maxway.uz/_next/data/ch7KmKvJ5azfPmlISTmjb/uz/branches.json");
    return MaxWayBranch.fromJson(response.data);
  }
}
