// ignore_for_file: missing_return
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/utils/constants.dart';
import '../utils/session.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

// or new Dio with a BaseOptions instance.

var options = BaseOptions(
    baseUrl: Constants.baseURL,
    receiveDataWhenStatusError: true,
    connectTimeout: 60 * 1000, // 60 seconds
    receiveTimeout: 60 * 1000 // 60 seconds
    );

// Global options
final cachOptions = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.request,
  hitCacheOnErrorExcept: [401, 403],
  maxStale: const Duration(days: 7),
  priority: CachePriority.normal,
  cipher: null,
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  allowPostMethod: false,
);

Dio dio = Dio(options);

class Api {
  static Future<List<ScheduleModel>> fetchSchedules(
      String travelDate, String route) async {
    List<ScheduleModel> responseData;

    try {
      var res = await dio
          .get(
        'schedules',
        queryParameters: {'date': travelDate, 'route': route},
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader:
                "Bearer " + await Session().get('access_token'),
          },
        ),
      )
          .catchError((e) {
        print(e);
      });

      if (res.statusCode == 200) {
        List data = res.data;

        // If the server did return a 200 OK response,
        // then parse the JSON.
        return data.map((e) => ScheduleModel.fromJson(e)).toList();
      }
    } on DioError catch (e) {
      return responseData;
    } catch (e) {
      return responseData;
    }
  }

  static Future<List<ScheduleModel>> fetchTodaySchedules(DateTime date) async {
    List<ScheduleModel> responseData;
    try {
      var res = await dio.get(
        'schedules',
        queryParameters: {
          'date': date.toString(),
        },
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader:
                "Bearer " + await Session().get('access_token'),
          },
        ),
      );

      if (res.statusCode == 200) {
        List data = res.data;

        // If the server did return a 200 OK response,
        // then parse the JSON.
        return data.map((e) => ScheduleModel.fromJson(e)).toList();
      }
      return responseData;
    } catch (e) {
      print(e);

      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
      return responseData;
    }
  }

  static Future<List<BookingModel>> getBookings(
      ScheduleModel scheduleModel) async {
    List<BookingModel> responseData;
    try {
      var res = await dio
          .get(
        'schedules/' + scheduleModel.scheduleNo,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader:
                "Bearer " + await Session().get('access_token'),
          },
        ),
      )
          .catchError((e) {
        print(e);
      });

      if (res.statusCode == 200) {
        List data = res.data;
        // If the server did return a 200 OK response,
        // then parse the JSON.
        return data.map((e) => BookingModel.fromJson(e)).toList();
      }
    } catch (e) {
      return responseData;
    }
  }

  static Future<List<RouteModel>> getRoutes() async {
    List<RouteModel> responseData;
    try {
      var res = await dio
          .get(
            'schedules/routes',
            options: Options(
              headers: {
                HttpHeaders.authorizationHeader:
                    "Bearer " + await Session().get('access_token'),
              },
            ),
          )
          .catchError((e) {});
      if (res.statusCode == 200) {
        List data = res.data;
        // If the server did return a 200 OK response,
        // then parse the JSON.
        return data.map((e) => RouteModel.fromJson(e)).toList();
      }
    } catch (e) {}

    return responseData;
  }

  static Future<dynamic> getTicket(ticket) async {
    try {
      var res = await dio
          .get(
        ticket + '/download',
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader:
                "Bearer " + await Session().get('access_token'),
          },
        ),
      )
          .catchError((e) {
        print(e);
      });
      if (res.statusCode == 200) {
        return res.data;
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<ScheduleModel> getSchedule(schedule) async {
    ScheduleModel responseData;
    try {
      var res = await dio
          .get(
        'schedules/' + schedule,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader:
                "Bearer " + await Session().get('access_token'),
          },
        ),
      )
          .catchError((e) {
        print(e);
      });
      if (res.statusCode == 200) {
        return jsonDecode(res.data.toString());
      }
    } catch (e) {
      print(e);
    }
    return responseData;
  }

  static Future<User> getUser() async {
    User user;
    try {
      var res = await dio
          .get(
        'profile',
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader:
                "Bearer " + await Session().get('access_token'),
          },
        ),
      )
          .catchError((e) {
        print(e);
      });
      if (res.statusCode == 200) {
        return User.fromJson(res.data);
      }
    } catch (e) {
      print(e);
    }
    return user;
  }

  static Future<BookingModel> getBooking(ticket) async {
    BookingModel responseData;
    try {
      var res = await dio
          .get(
        'bookings/' + ticket,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader:
                "Bearer " + await Session().get('access_token'),
          },
        ),
      )
          .catchError((e) {
        print(e);
      });
      if (res.statusCode == 200) {
        print('Found ticket');
        return BookingModel.fromJson(res.data);
      }
    } catch (e) {
      print(e);
    }
    return responseData;
  }

  static Future<List<BookingModel>> createBooking(ScheduleModel schedule,
      List<PassengerModel> passengers, selectedMethod) async {
    List<BookingModel> responseData;
    try {
      var res = await dio.post('bookings/batch',
          data: {
            'schedule': schedule.scheduleNo,
            'passengers': passengers.map((e) => e.toJson()).toList(),
            'payment_method': selectedMethod.toString().toLowerCase()
          },
          options: Options(
            headers: {
              HttpHeaders.authorizationHeader:
                  "Bearer " + await Session().get('access_token'),
            },
          ));

      if (res.statusCode == 200) {
        List data = res.data;

        // If the server did return a 200 OK response,
        // then parse the JSON.
        return data.map((e) => BookingModel.fromJson(e)).toList();
      } else if (res.statusCode == 422) {
        Fluttertoast.showToast(
          msg: res.data.toString(),
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
      return responseData;
    } on DioError catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: e.response.data.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );

      return responseData;
    } catch (e) {
      print(e);
      return responseData;
    }
  }

  static Future<dynamic> refreshAuth() async {
    try {
      var res = await dio.post(
        'auth/refresh',
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader:
                "Bearer " + await Session().get('access_token'),
          },
        ),
      );
      if (res.statusCode == 200) {
        return res.data;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
