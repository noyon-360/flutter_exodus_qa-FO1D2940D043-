import 'package:exodus/core/utils/debug_logger.dart';
import 'package:exodus/data/models/auth/user_response.dart';
import 'package:exodus/data/models/ticket/ticket_model.dart';

class UserData {
  final User user;
  final List<TicketModel> ticket;

  UserData({required this.user, required this.ticket});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      user: User.fromJson(json['user'] ?? {}),
      ticket:
          (json['ticket'] as List<dynamic>?)
              ?.map((e) => TicketModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
