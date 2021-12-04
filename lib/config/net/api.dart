import 'package:dio/dio.dart';
import 'package:yuyan_app/config/app.dart';
import 'package:yuyan_app/config/net/base.dart';
import 'package:yuyan_app/config/net/token.dart';
import 'package:yuyan_app/model/meta/meta.dart';

class ApiResponse {
  late dynamic data;
  late int status;
  late String message;

  late Map meta;
  late MetaSeri metaSeri;

  late Map _raw;

  Map get raw => _raw;

  ApiResponse.fromJson(Map json) {
    if (json == null) return;
    _raw = json;
    data = json['data'];
    status = json['status'];
    message = json['message'];
    meta = json['meta'];
    if (meta != null) {
      metaSeri = MetaSeri.fromJson(meta);
    }
  }

  bool isError() {
    return data == null;
  }

  String errorDescription() {
    return 'ApiResponseError: $status $message';
  }
}

class ApiInterceptor extends InterceptorsWrapper {
  @override
  Future<Response> onResponse(Response response) async {
    var resp = ApiResponse.fromJson(response.data);
    if (resp.isError()) {
      throw ApiError(
        response: resp,
        dio: DioError(
          request: response.request,
          response: response,
        ),
      );
    }
    response.data = resp;
    return response;
  }

  @override
  Future onError(DioError err) async {
    var resp = ApiResponse.fromJson(err.response?.data);
    if (resp.isError()) {
      return ApiError(
        response: resp,
        dio: err,
      );
    }
    return err;
  }
}

class ApiError implements Exception {
  ApiResponse response;
  DioError dio;

  ApiError({
    required this.response,
    required this.dio,
  });

  @override
  String toString() {
    var desc = response.errorDescription();
    return '${dio.request!.method} ${dio.request!.path} => $desc';
  }
}

class BaseApi extends BaseHttp with TokenMixin, OrganizationMixin {
  final baseUrl;
  final userAgent = Config.userAgent;

  BaseApi({
    this.baseUrl = "https://www.yuque.com/api",
  });

  @override
  void init() {
    options.baseUrl = baseUrl;
    interceptors.add(ApiInterceptor());
    options.headers['User-Agent'] = userAgent;
    // options.headers['Content-Type'] = "application/json";

    super.init();
  }
}
