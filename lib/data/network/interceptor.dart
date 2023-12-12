import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

const String APPLICATION_JSON = "application/json";
const String CONTENT_TYPE = "content-type";
const String ACCEPT = "accept";
const String AUTHORIZATION = "authorization";
const String DEFAULT_LANGUAGE = "en";
const String TOKEN = "token";
const String coreHost = "https://api.example.com";
const String testHost = 'https://jsonplaceholder.typicode.com';

class DioFactory {
  Dio getDio({bool isCore = true}) {
    Dio dio = Dio();

    Map<String, String> headers = {
      CONTENT_TYPE: APPLICATION_JSON,
      ACCEPT: APPLICATION_JSON,
      AUTHORIZATION: TOKEN,
      DEFAULT_LANGUAGE: DEFAULT_LANGUAGE
    };

    dio.options = BaseOptions(
      baseUrl: isCore ? coreHost : testHost,
      headers: headers,
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (req, handle) {
          return handle.next(req);
        },
        onResponse: (res, handle) {
          return handle.next(res);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );

    if (!kReleaseMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: false,
        ),
      );
    }

    return dio;
  }
}

enum DataSource {
  SUCCESS,
  NO_CONTENT,
  BAD_REQUEST,
  FORBIDDEN,
  UNAUTORISED,
  NOT_FOUND,
  INTERNAL_SERVER_ERROR,
  DEFAULT,
  CONNECT_TIMEOUT,
  SEND_TIMEOUT,
  RECIEVE_TIMEOUT,
  CANCEL
}

extension DataSourceExtension on DataSource {
  Failure getFailure() {
    switch (this) {
      case DataSource.SUCCESS:
        return Failure(
            ResponseCode.SUCCESS, "ResponseMessage.SUCCESS.tr(mContext)");
      case DataSource.NO_CONTENT:
        return Failure(
            ResponseCode.NO_CONTENT, "ResponseMessage.NO_CONTENT.tr(mContext)");
      case DataSource.BAD_REQUEST:
        return Failure(ResponseCode.BAD_REQUEST,
            "ResponseMessage.BAD_REQUEST.tr(mContext)");
      case DataSource.FORBIDDEN:
        return Failure(
            ResponseCode.FORBIDDEN, "ResponseMessage.FORBIDDEN.tr(mContext)");
      case DataSource.UNAUTORISED:
        return Failure(ResponseCode.UNAUTORISED,
            "ResponseMessage.UNAUTORISED.tr(mContext)");
      case DataSource.NOT_FOUND:
        return Failure(
            ResponseCode.NOT_FOUND, "ResponseMessage.NOT_FOUND.tr(mContext)");
      case DataSource.INTERNAL_SERVER_ERROR:
        return Failure(ResponseCode.INTERNAL_SERVER_ERROR,
            "ResponseMessage.INTERNAL_SERVER_ERROR.tr(mContext)");
      case DataSource.DEFAULT:
        return Failure(
            ResponseCode.DEFAULT, "ResponseMessage.DEFAULT.tr(mContext)");
      default:
        return Failure(
            ResponseCode.DEFAULT, "ResponseMessage.DEFAULT.tr(mContext)");
    }
  }
}

class ResponseCode {
  static const int SUCCESS = 200; // success with data
  static const int NO_CONTENT = 201; // success with no data (no content)
  static const int BAD_REQUEST = 400; // failure, API rejected request
  static const int UNAUTORISED = 401; // failure, user is not authorised
  static const int FORBIDDEN = 403; //  failure, API rejected request
  static const int INTERNAL_SERVER_ERROR = 500; // failure, crash in server side
  static const int NOT_FOUND = 404; // failure, not found

  // local status code
  static const int CONNECT_TIMEOUT = -1;
  static const int CANCEL = -2;
  static const int RECIEVE_TIMEOUT = -3;
  static const int SEND_TIMEOUT = -4;
  static const int CACHE_ERROR = -5;
  static const int NO_INTERNET_CONNECTION = -6;
  static const int DEFAULT = -7;
}

class ResponseMessage {
  static const String SUCCESS = "success"; // success with data
  static const String NO_CONTENT =
      "success"; // success with no data (no content)
  static const String BAD_REQUEST =
      "bad request. try again later"; // failure, API rejected request
  static const String UNAUTORISED =
      "user unauthorized, try again later"; // failure, user is not authorised
  static const String FORBIDDEN =
      "forbidden request. try again later"; //  failure, API rejected request
// static const String INTERNAL_SERVER_ERROR = AppStrings.strInternalServerError; // failure, crash in server side
// static const String NOT_FOUND = AppStrings.strNotFoundError; // failure, crash in server side
//
// // local status code
// static const String CONNECT_TIMEOUT = AppStrings.strTimeoutError;
// static const String CANCEL = AppStrings.strDefaultError;
// static const String RECIEVE_TIMEOUT = AppStrings.strTimeoutError;
// static const String SEND_TIMEOUT = AppStrings.strTimeoutError;
// static const String CACHE_ERROR = AppStrings.strCacheError;
// static const String NO_INTERNET_CONNECTION = AppStrings.strNoInternetError;
// static const String DEFAULT = AppStrings.strDefaultError;
}

class Failure {
  int code; // 200, 201, 400, 303..500 and so on
  String message; // error , success

  Failure(this.code, this.message);
}
