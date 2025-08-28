import 'package:exodus/core/utils/debug_logger.dart';
import 'package:exodus/data/models/bus/available_bus_response.dart';

class TicketModel {
  final String id;
  final String scheduleId;
  final String userId;
  final double price;
  final Bus bus;
  final String seatNumber;
  final String source;
  final String destination;
  final DateTime date;
  final String time;
  final String? qrCode;
  final String? ticketSecret;
  final List<String>? availableSeat;
  final String status;
  final String key;

  TicketModel({
    required this.id,
    required this.scheduleId,
    required this.userId,
    required this.price,
    required this.bus,
    required this.seatNumber,
    required this.source,
    required this.destination,
    required this.date,
    required this.time,
    this.qrCode,
    this.ticketSecret,
    this.availableSeat,
    required this.status,
    required this.key,
  });
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    dPrint("Bus Number -> $json");
    return TicketModel(
      id: json['_id'] ?? '',
      scheduleId:
          json['schedule'] is Map<String, dynamic>
              ? json['schedule']['_id'] ?? ''
              : json['schedule'] ?? '',
      userId:
          json['userId'] is Map<String, dynamic>
              ? json['userId']['_id'] ?? ''
              : json['userId'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      bus: Bus.fromJson(json['busNumber'] ?? {}),
      // json['busNumber'] is Map<String, dynamic>
      //     ? json['busNumber']['_id'] ?? ''
      //     : json['busNumber'] ?? '',
      seatNumber: json['seatNumber'] ?? '',
      source: json['source'] ?? '',
      destination: json['destination'] ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      time: json['time'] ?? '',
      qrCode: json['qrCode'],
      ticketSecret: json['ticket_secret'],
      availableSeat:
          json['avaiableSeat'] != null
              ? List<String>.from(json['avaiableSeat'])
              : null,
      status: json['status'] ?? 'pending',
      key: json['key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'schedule': scheduleId,
      'userId': userId,
      'price': price,
      'busNumber': bus,
      'seatNumber': seatNumber,
      'source': source,
      'destination': destination,
      'date': date.toIso8601String(),
      'time': time,
      'qrCode': qrCode,
      'ticket_secret': ticketSecret,
      'avaiableSeat': availableSeat,
      'status': status,
      'key': key,
    };
  }
}
