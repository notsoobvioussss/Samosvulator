import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient(this.dio) {
    dio.options = BaseOptions(
      baseUrl: "https://api.tomikartemik.ru",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

    // 🔹 Добавляем Interceptor для логирования
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("\n📤 [DIO REQUEST]");
        print("➡️ URL: ${options.baseUrl}${options.path}");
        print("➡️ Method: ${options.method}");
        print("➡️ Headers: ${options.headers}");
        print("➡️ Query Params: ${options.queryParameters}");
        print("➡️ Body: ${options.data}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("\n✅ [DIO RESPONSE]");
        print("⬅️ Status Code: ${response.statusCode}");
        print("⬅️ Data: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("\n❌ [DIO ERROR]");
        print("⛔ Status Code: ${e.response?.statusCode}");
        print("⛔ Message: ${e.message}");
        print("⛔ Response Data: ${e.response?.data}");
        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String path, { String? token}) async {
    return await dio.get(
      path,
      options: Options(headers: token != null ? {"Authorization": "Bearer $token"} : null),
    );
  }

  Future<Response> post(String path, {dynamic data, String? token}) async {
    return await dio.post(
      path,
      data: data,
      options: Options(headers: token != null ? {"Authorization": "Bearer $token"} : null),
    );
  }
}