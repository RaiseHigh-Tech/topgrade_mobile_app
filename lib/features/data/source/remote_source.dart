import 'package:dio/dio.dart';

import '../../../common/error/response_exception.dart';
import '../../../common/error/server_exception.dart';
import '../../../utils/network/dio_client.dart';
import '../model/demo_model.dart';


abstract class RemoteSource {
  final DioClient dio; // don't forget to add this in pubspec.yaml
  RemoteSource({required this.dio});

  Future<DemoModel> demoLogin({
    required String email,
    required String password,
  });
}

class RemoteSourceImpl extends RemoteSource {
  RemoteSourceImpl({required super.dio});

  @override
  Future<DemoModel> demoLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return DemoModel.fromJson(response.data);
      } else {
        throw ServerException(message: "This response code is not 200 or 201");
      }
    } catch (e) {
      if (e is DioException && e.response!.statusCode == 400) {
        // replace 'error' with the actual error key in your API response
        throw ResponseException(message: e.response!.data['error'].toString());
      } else if (e is DioException && e.response!.statusCode == 500) {
        throw ResponseException(message: e.response!.data.toString());
      }
      throw ServerException(message: e.toString());
    }
  }
}
