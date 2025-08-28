import 'package:exodus/core/network/api_client.dart';
import 'package:exodus/domain/repositories/create_ticket_repository.dart';

import '../../core/constants/api/api_constants_endpoints.dart';
import '../../core/network/network_result.dart';
import '../models/ticket/ticket_model.dart';

class CreateTicketRepositoryImpl implements CreateTicketRepository {
  final ApiClient _apiClient;

  CreateTicketRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  NetworkResult<TicketModel> generateTicket(
    String seatNumber,
    String busNumber,
    String source,
    String destination,
    DateTime date,
  ) async {
    return _apiClient.post<TicketModel>(
      ApiEndpoints.createTicket,
      data: {
        "seatNumber": seatNumber,
        "busNumber": busNumber,
        "source": source,
        "destination": destination,
        "date": date.toUtc().toIso8601String(),
      },
      fromJsonT: (json) => TicketModel.fromJson(json),
    );
  }
}
