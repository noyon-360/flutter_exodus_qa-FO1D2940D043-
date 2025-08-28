import 'package:exodus/core/controller/base_controller.dart';
import 'package:exodus/domain/usecases/home/get_home_data.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/services/app_state_service.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../../../data/models/auth/user_data_response.dart';

class HomeController extends BaseController {
  // Add AppStateService to the constructor
  final AppStateService _appStateService;
  final GetHomeDataUsecase _getHomeDataUsecase;

  HomeController(this._appStateService, this._getHomeDataUsecase);

  final ValueNotifier<UserData?> userDataNotifier = ValueNotifier(null);
  final ValueNotifier<int?> rideLeft = ValueNotifier(0);
  final ValueNotifier<int?> rewardPoint = ValueNotifier(0);

  Future<UserData?> getUserData() async {
    setLoading(true);
    notifyListeners();

    try {
      final result = await _getHomeDataUsecase.call();

      result.fold((failure) {}, (data) {
        userDataNotifier.value = data.data;
        _appStateService.setUser(data.data);

        // Count tickets with status 'panding'
        final pendingCount =
            data.data.ticket
                .where((ticket) => ticket.status == 'pending')
                .length;

        dPrint("User Data Ticket Status -> $pendingCount");
        rideLeft.value = pendingCount;

        // If all tickets are complete, set rewardPoint to 1
        final allComplete =
            data.data.ticket.isNotEmpty &&
            data.data.ticket.every((ticket) => ticket.status == 'completed');
        rewardPoint.value = allComplete ? 1 : 0;

        return data;
      });
      notifyListeners();

      // if (result is ApiSuccess<UserData>) {
      // final data = result.data;
      // userDataNotifier.value = result.data;
      // _appStateService.setUser(result.data);
      // dPrint("User Data Print -> ${data.user.email}");

      // return data;
      // }
    } finally {
      setLoading(false);
      notifyListeners();
    }
    return null;
  }
}
