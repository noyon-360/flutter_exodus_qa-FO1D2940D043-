import 'package:exodus/core/controller/base_controller.dart';
import 'package:exodus/core/network/api_result.dart';
import 'package:exodus/core/network/extensions/either_extensions.dart';
import 'package:exodus/core/utils/debug_logger.dart';
import 'package:exodus/data/models/bus/available_bus_response.dart';
import 'package:exodus/data/models/bus/single_bus_response.dart';
import 'package:exodus/domain/usecases/bookARide/get_single_bus_data_usecase.dart';
import 'package:exodus/domain/usecases/bookARide/list_of_available_suttles_usecase.dart';
import 'package:exodus/domain/usecases/bookARide/list_of_routes_usecase.dart';
import 'package:exodus/presentation/core/services/app_data_store.dart';
import 'package:exodus/presentation/screens/book_a_ride/model/shuttle_query.dart';

class ListOfRoutsController extends BaseController {
  // use case for ListOfRoutsController
  final ListOfRoutesUsecase _listOfRoutesUsecase;
  final GetAvailableShuttlesUseCase _getAvailableShuttlesUseCase;
  final GetSingleBusDataUsecase _getSingleBusDataUsecase;

  ListOfRoutsController(
    this._listOfRoutesUsecase,
    this._getAvailableShuttlesUseCase,
    this._getSingleBusDataUsecase,
  );

  List<AvailableShuttle> availableShuttlesList = [];

  Future<void> getListOfRoutes() async {
    setLoading(true);
    final result = await _listOfRoutesUsecase.call();
    setLoading(false);

    result.handle(
      onSuccess: (data) {
        dPrint("List of Routes: $data");

        AppDataStore().routesList = data.data;

        // return the data
        notifyListeners();
      },
      onFailure: (failure) {
        setError(failure.message);
        dPrint("Controller login message print ${failure.message}");
        notifyListeners();
      },
    );
    // if (result is ApiSuccess<List<String>>) {
    //   final data = result.data;
    //   dPrint("List of Routes: $data");

    //   AppDataStore().routesList = data;

    //   // return the data
    //   notifyListeners();
    //   // return data;
    // } else {
    //   final message = (result as ApiError).message;
    //   setError(message);
    //   dPrint(" Controller login message print $message");
    //   notifyListeners();
    //   // return [];
    // }
  }

  // Available Shuttles
  Future<List<AvailableShuttle>> getAvailableShuttles(
    String from,
    String to,
    String date,
  ) async {
    setLoading(true);
    final query = ShuttleQuery(
      from: from,
      to: to,
      date: date,
    );
    final result = await _getAvailableShuttlesUseCase.call(query);
    setLoading(false);

    result.fold(
      (failure) {
        setError(failure.message);
        dPrint("Controller login message print ${failure.message}");
        notifyListeners();
      },
      (data) {
        availableShuttlesList = data.data;

        // return the data
        notifyListeners();
      },
    );
    return availableShuttlesList;

    // result.handle(
    //   onSuccess: (data) {
    //     dPrint("Available Shuttles: $data");

    //     availableShuttlesList = data;

    //     // return the data
    //     notifyListeners();
    //   },
    //   onFailure: (failure) {
    //
    //   },
    // );

    // return availableShuttlesList;

    // if (result is ApiSuccess<List<AvailableShuttle>>) {
    //   final data = result.data;
    //   dPrint("Available Shuttles: $data");

    //   availableShuttlesList = data;

    //   return availableShuttlesList;

    //   // return the data
    //   // notifyListeners();
    //   // return data;
    // } else {
    //   final message = (result as ApiError).message;
    //   setError(message);
    //   dPrint(" Controller login message print $message");
    //   return [];
    //   // notifyListeners();
    //   // return [];
    // }
  }

  Future<BusDetailResponse> getSingleBusDetails(
    String busId,
    String source,
    String destination,
    String date,
    String time,
  ) async {
    try {
      final result = await _getSingleBusDataUsecase.call(
        busId,
        source,
        destination,
        date,
        time,
      );

      dPrint("list_of_routes -> ${result}");

      final busDetails = result.fold(
        (failure) {
          setError(failure.message);
          dPrint("Failed to fetch bus details: ${failure.message}");
          throw Exception("Failed to fetch bus details");
        },
        (data) {
          dPrint("single bus result -> ${data.data.bus.busNumber}");
          return data.data;
        },
      );

      return busDetails;

      // if (result is ApiSuccess<BusDetailResponse>) {
      //   return result.data;
      // }
    } catch (e) {
      dPrint(e);
    }
    throw Exception("Failed to fetch bus details");
  }
}
