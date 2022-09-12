import 'dart:convert';

import 'package:flutter/material.dart';

class RouteModel {
  int id;
  String name;
  List<BoardingModel> boardingPoints;
  List<BoardingModel> droppingPoints;

  RouteModel({this.id, this.name, this.boardingPoints, this.droppingPoints});

  RouteModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['boarding_points'] != null) {
      List boardingData = json['boarding_points'];
      boardingPoints =
          boardingData.map((e) => BoardingModel.fromJson(e)).toList();
    }
    if (json['dropping_points'] != null) {
      List droppingData = json['dropping_points'];
      droppingPoints =
          droppingData.map((e) => BoardingModel.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class BoardingModel {
  String id;
  String name;

  BoardingModel({this.id, this.name});

  BoardingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class SubRouteModel {
  int id;
  int boardingPointId;
  int droppingPointId;
  String point;
  BoardingModel droppintPoint;
  BoardingModel boardingPoint;
  int amount;

  SubRouteModel(
      {this.id,
      this.boardingPointId,
      this.droppingPointId,
      this.amount,
      this.point,
      this.boardingPoint,
      this.droppintPoint});

  SubRouteModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    boardingPointId = json['boarding_point_id'];
    droppingPointId = json['dropping_point_id'];
    point = json['point'];
    droppintPoint = json['boarding_point'] != null
        ? BoardingModel.fromJson(json['boarding_point'])
        : null;
    boardingPoint = json['droppping_point'] != null
        ? BoardingModel.fromJson(json['droppping_point'])
        : null;
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['amount'] = this.amount;
    data['boarding_point_id'] = this.boardingPointId;
    data['dropping_point_id'] = this.droppingPointId;
    return data;
  }
}

class PassengerModel {
  String fullName;
  String phoneNumber;
  String seatNo;
  BoardingModel boardingPoint;
  BoardingModel droppingPoint;
  SubRouteModel subRoute;
  int amount;

  PassengerModel(
      {this.fullName,
      this.phoneNumber,
      this.seatNo,
      this.amount,
      this.boardingPoint,
      this.subRoute,
      this.droppingPoint});

  PassengerModel.fromJson(Map<String, dynamic> json) {
    fullName = json['full_name'];
    phoneNumber = json['phone_number'].toString();
    seatNo = json['seat_no'].toString();
    amount = json['amount'];
    subRoute = json['sub_routes'] != null
        ? SubRouteModel.fromJson(json['sub_routes'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['full_name'] = this.fullName;
    data['phone_number'] = this.phoneNumber;
    data['seat_no'] = this.seatNo;
    data['boarding_point'] =
        this.boardingPoint != null ? this.boardingPoint.id : null;
    data['dropping_point'] =
        this.droppingPoint != null ? this.droppingPoint.id : null;
    data['amount'] = this.amount;
    data['sub_route_id'] = this.subRoute != null ? this.subRoute.id : null;
    return data;
  }
}

class ScheduleModel {
  String id;
  String name;
  String scheduleNo;
  String route;
  String bus;
  String date;
  String origin;
  String destination;
  String fare;
  String visibility;
  String depart;
  String busType;
  int totalAvailableSeats;
  int totalReservedSeats;
  int totalSeats;
  int totalBookings;
  String company;
  String reservedSeats;
  List availableSeats;
  List selectedSeats;
  String seatLayout;
  List<dynamic> seatChart;
  List unavailableSeats;
  List seatRender;
  bool isPast;
  bool isEnRoute;
  bool isFuture;
  bool isPrivate;
  bool isBusFull;
  bool isAvailable;
  List<BoardingModel> boardingPoints;
  List<BoardingModel> droppingPoints;
  List<SubRouteModel> subRoutes;
  String progress;
  int progressPercentage;
  String reportTime;
  String arrivalTime;
  String departureTime;
  String formattedAmount;
  List<BookingModel> bookings;

  ScheduleModel(
      {this.id,
      this.name,
      this.origin,
      this.destination,
      this.date,
      this.availableSeats,
      this.bus,
      this.busType,
      this.company,
      this.depart,
      this.fare,
      this.isBusFull,
      this.isFuture,
      this.isPast,
      this.isEnRoute,
      this.isPrivate,
      this.isAvailable,
      this.progress,
      this.reservedSeats,
      this.selectedSeats,
      this.scheduleNo,
      this.seatChart,
      this.seatLayout,
      this.totalSeats,
      this.subRoutes,
      this.seatRender,
      this.totalAvailableSeats,
      this.totalBookings,
      this.unavailableSeats,
      this.route,
      this.boardingPoints,
      this.droppingPoints,
      this.visibility,
      this.bookings,
      this.progressPercentage,
      this.totalReservedSeats,
      this.arrivalTime,
      this.departureTime,
      this.formattedAmount,
      this.reportTime});

  ScheduleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'];
    scheduleNo = json['schedule_no'];
    departureTime = json['departure_time'];
    reportTime = json['report_time'];
    arrivalTime = json['arrival_time'];
    progressPercentage = json['progress_percentage'];
    totalAvailableSeats = json['total_available_seats'];
    totalReservedSeats = json['total_reserved_seats'];
    totalSeats = json['total_seats'];
    origin = json['origin'];
    destination = json['destination'];
    date = json['date'];
    availableSeats = json['available_seats'];
    unavailableSeats = json['unavailable_seats'];
    busType = json['bus_type'];
    bus = json['bus'];
    company = json['company'];
    fare = json['fare'].toString();
    totalBookings = json['total_bookings'];
    visibility = json['visibility'];
    isBusFull = json['is_bus_full'] == true;
    isPast = json['is_past'] == true;
    isEnRoute = json['is_en_route'] == true;
    isAvailable = json['is_available'] == true;
    isFuture = json['is_future'] == true;
    isPrivate = json['is_private'] == true;
    seatLayout = json['seat_layout'].toString();
    reservedSeats = json['reserved_seats'].toString();
    selectedSeats = json['selected_seats'];
    seatChart = json['seat_chart'];
    progress = json['progress'].toString();
    depart = json['depart'];
    route = json['route'];
    if (json['boarding_points'] != null) {
      List boardingData = json['boarding_points'];
      boardingPoints =
          boardingData.map((e) => BoardingModel.fromJson(e)).toList();
    }
    if (json['dropping_points'] != null) {
      List droppingData = json['dropping_points'];
      droppingPoints =
          droppingData.map((e) => BoardingModel.fromJson(e)).toList();
    }
    if (json['sub_routes'] != null) {
      List subRouteData = json['sub_routes'];
      print(json['sub_routes']);
      subRoutes = subRouteData.map((e) => SubRouteModel.fromJson(e)).toList();
    }
    if (json['bookings'] != null) {
      List bookingData = json['bookings'];
      bookings = bookingData.map((e) => BookingModel.fromJson(e)).toList();
    }
  }
}

class BookingModel {
  String ticketNo;
  String seatNo;
  String scheduleNo;
  String requiredPayment;
  String totalAmount;
  bool reserved;
  bool confirmed;
  bool pendingPayment;
  String bus;
  String busClass;
  String company;
  String ticketUrl;
  String origin;
  String destination;
  String name;
  String phone;
  String travelDate;
  String email;
  String status;
  RouteModel route;
  String fare;
  String statusLabel;
  String channel;
  String boardingPoint;
  String droppingPoint;
  ScheduleModel schedule;
  String expireAt;
  int minutesToExpire;
  String departureTime;
  String issuedAt;
  String receipt;
  String createdAt;
  Color statusColor;
  String issuedBy;

  BookingModel(
      {this.ticketNo,
      this.origin,
      this.destination,
      this.schedule,
      this.boardingPoint,
      this.seatNo,
      this.name,
      this.company,
      this.phone,
      this.fare,
      this.bus,
      this.travelDate,
      this.route,
      this.channel,
      this.confirmed,
      this.createdAt,
      this.email,
      this.expireAt,
      this.issuedBy,
      this.minutesToExpire,
      this.pendingPayment,
      this.requiredPayment,
      this.reserved,
      this.status,
      this.scheduleNo,
      this.statusLabel,
      this.receipt,
      this.departureTime,
      this.droppingPoint,
      this.totalAmount,
      this.issuedAt,
      this.statusColor,
      this.busClass,
      this.ticketUrl});

  BookingModel.fromJson(Map<String, dynamic> json) {
    ticketNo = json['ticket'];
    scheduleNo = json['schedule_no'];
    origin = json['origin'];
    seatNo = json['seat_no'].toString();
    destination = json['destination'];
    travelDate = json['travel_date'];
    expireAt = json['expire_at'];
    schedule = json['unavailable_seats'];
    busClass = json['bus_class'];
    bus = json['bus'];
    company = json['company'];
    fare = json['fare'].toString();
    statusLabel = json['status'];
    phone = json['phone'];
    status = json['status'];
    channel = json['channel'];
    confirmed = json['confirmed'] == true;
    departureTime = json['depart'];
    receipt = json['receipt'];
    reserved = json['reserved'] == true;
    pendingPayment = json['pending_payment'] == true;
    issuedBy = json['issued_by'];
    minutesToExpire = json['minutes_to_expire'];
    name = json['name'];
    createdAt = json['created_date'];
    schedule = json['schedule'] != null
        ? ScheduleModel.fromJson(json['schedule'])
        : null;
    route = json['route'] != null ? RouteModel.fromJson(json['route']) : null;
    boardingPoint = json['boarding_point'];
    droppingPoint = json['dropping_point'];
    totalAmount = json['total_amount'].toString();
    ticketUrl = json['ticket_url'];
    issuedAt = json['issued_at'];
    statusColor = json['confirmed'] == true
        ? Colors.teal.shade700
        : (json['reserved'] == true
            ? Colors.black87
            : Colors.deepOrange.shade700);
  }
}

class User {
  String id;
  String firstName;
  String lastName;
  String phone;
  String email;
  String accessToken;
  String designation;
  RouteModel route;
  List<Role> roles;
  UserData data =
      UserData(todayTickets: 0, totalMonthlyTickets: 0, totalTickets: 0);

  User(
      {this.id,
      this.firstName,
      this.lastName,
      this.phone,
      this.email,
      this.route,
      this.roles,
      this.designation,
      this.accessToken});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    firstName = json['first_name'];
    lastName = json['last_name'];
    phone = json['phone_number'].toString();
    email = json['email'];
    designation = json['designation'];
    accessToken = json['acess_token'] != null ? json['access_token'] : null;

    if (json['roles'] != null) {
      List roleData = json['roles'];
      roles = roleData.map((e) => Role.fromJson(e)).toList();
    }
    if (json['route'] != null) {
      route = RouteModel.fromJson(json['route']);
    }

    if (json['data'] != null) {
      data = UserData.fromJson(json['data']);
    }
  }
}

class UserData {
  UserData({this.todayTickets, this.totalTickets, this.totalMonthlyTickets});

  int todayTickets = 0;
  int totalTickets = 0;
  int totalMonthlyTickets = 0;

  UserData.fromJson(Map<String, dynamic> json) {
    totalTickets = json['total_tickets'] ?? 0;
    todayTickets = json['total_today'] ?? 0;
    totalMonthlyTickets = json['total_monthly_tickets'] ?? 0;
  }
}

class Role {
  Role({
    this.id,
    this.name,
  });

  String id;
  String name;

  Role.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'];
  }
}
