import 'package:dio/dio.dart';
import 'package:yuyan_app/config/app.dart';
import 'package:yuyan_app/config/net/base.dart';
import 'package:yuyan_app/config/net/token.dart';
import 'package:yuyan_app/model/meta/meta.dart';

class ApiResponse {
  dynamic data;
  int? status;
  String? message;

  Map? meta;
  MetaSeri? metaSeri;

  Map? _raw;

  Map? get raw => _raw;

  ApiResponse.fromJson(Map? json) {
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
    return data == null && status != null;
  }

  String errorDescription() {
    return 'ApiResponseError: $status $message';
  }
}

class ApiInterceptor extends InterceptorsWrapper {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final resp = ApiResponse.fromJson(response.data);
    if (resp.isError()) {
      throw ApiError(
        response: resp,
        dio: DioError(
          requestOptions: response.requestOptions,
          response: response,
          type: DioErrorType.response,
        ),
      );
    }
    response.data = resp;
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    final resp = ApiResponse.fromJson(err.response?.data);
    if (resp.isError()) {
      // TODO: fix error
    }
    handler.next(err);
  }
  // @override
  // Future<Response> onResponse(Response response) async {
  //   var resp = ApiResponse.fromJson(response.data);
  //   if (resp.isError()) {
  //     throw ApiError(
  //       response: resp,
  //       dio: DioError(
  //         request: response.request,
  //         response: response,
  //       ),
  //     );
  //   }
  //   response.data = resp;
  //   return response;
  // }

  // @override
  // Future onError(DioError err) async {
  //   var resp = ApiResponse.fromJson(err.response?.data);
  //   if (resp.isError()) {
  //     return ApiError(
  //       response: resp,
  //       dio: err,
  //     );
  //   }
  //   return err;
  // }
}

class ApiError implements Exception {
  ApiResponse? response;
  DioError? dio;

  ApiError({
    this.response,
    this.dio,
  });

  @override
  String toString() {
    var desc = response!.errorDescription();
    if (dio != null) {
      return '${dio!.requestOptions.method} ${dio!.requestOptions.path} => $desc';
    }
    return desc;
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
