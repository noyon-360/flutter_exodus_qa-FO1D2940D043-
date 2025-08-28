import 'package:exodus/core/di/service_locator.dart';
import 'package:exodus/core/routes/app_routes.dart';
import 'package:exodus/core/utils/debug_logger.dart';
import 'package:exodus/core/utils/extensions/string_extensions.dart';
import 'package:exodus/presentation/core/services/app_data_store.dart';
import 'package:exodus/presentation/screens/book_a_ride/controllers/list_of_routs.dart';
import 'package:exodus/presentation/screens/book_a_ride/widgets/bottom_sheet_route_list.dart';

import '../../../../core/services/navigation_service.dart';
import 'package:exodus/presentation/widgets/build_title.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app/app_colors.dart';
import '../../../../core/constants/app/app_gap.dart';
import '../../../../core/constants/app/app_sizes.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../theme/app_styles.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/arrow_icon_widget.dart';

class BookARideScreen extends StatefulWidget {
  const BookARideScreen({super.key});

  @override
  State<BookARideScreen> createState() => _BookARideScreenState();
}

class _BookARideScreenState extends State<BookARideScreen> {
  final controller = sl<ListOfRoutsController>();

  final ValueNotifier<String> fromSelectNotifier = ValueNotifier<String>(
    'Any location',
  );
  final ValueNotifier<String> toSelectNotifier = ValueNotifier<String>(
    'Any location',
  );

  String toSelect = '';
  String fromSelect = '';
  late String selectedDate = "";
  int selectedDateIndex = 0;
  // String formattedSelectedDate = '';

  @override
  void initState() {
    super.initState();
    controller.getListOfRoutes();
  }

  ///`!` [Todd] check the global core use
  // String _formatDate(DateTime date) {
  //   return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  // }

  Future<void> _getAvailableShuttles() async {
    if (toSelect.isEmpty || fromSelect.isEmpty) {
      // Show an error message or handle the case where selections are not made
      dPrint("Please select both 'From' and 'To' locations and a date.");
      return;
    } else {
      controller.getAvailableShuttles(fromSelect, toSelect, selectedDate);
    }
  }

  // Future<void> _getSingleBusDetails() async {
  //   controller.getSingleBusDetails(busId, source, destination, date, time)
  // }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      removePadding: true,
      appBar: AppBar(
        title: Text("Book a Ride", style: AppText.h2),
        actions: [
          /// [Reserve Bus] button
          GestureDetector(
            onTap: () {
              ///`?` [TODO] Implement Reserve Bus functionality
              NavigationService().sailTo(AppRoutes.reserveBus);
            },
            child: Container(
              width: 117,
              height: 37,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                gradient: AppColors.primaryGradient,
              ),
              child: Center(
                child: Text(
                  "Reserve Bus",
                  style: AppText.smallMedium.copyWith(
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
          ),
          Gap.w18,
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _locationSelect(),
          Gap.h24,
          _dateSelect(),
          Gap.h24,
          TitleTextWidget(title: "Available Shuttles"),
          Gap.h16,
          _availableShuttles(),

          Gap.bottomAppBarGap,
        ],
      ),
    );
  }

  /// [Location Select] widget
  ///
  Widget _locationSelect() {
    return Padding(
      padding: AppSizes.paddingHorizontalMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.secondary,
              ),
              Gap.w8,
              Text("From", style: AppText.bodyRegular),
            ],
          ),
          Gap.h16,
          GestureDetector(
            onTap: () {
              controller.getListOfRoutes();
              showLocationBottomSheet(context, AppDataStore().routesList).then((
                value,
              ) {
                if (value != null && value.isNotEmpty) {
                  fromSelect = value;
                  fromSelectNotifier.value = value;
                  dPrint("Selected route: $value");
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.secondary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: fromSelectNotifier,
                    builder: (context, value, _) {
                      return Text(value, style: AppText.bodyRegular);
                    },
                  ),
                ],
              ),
            ),
          ),

          Gap.h16,
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.secondary,
              ),
              Gap.w8,
              Text("To", style: AppText.bodyRegular),
            ],
          ),
          Gap.h8,
          GestureDetector(
            onTap: () {
              controller.getListOfRoutes();
              showLocationBottomSheet(context, AppDataStore().routesList).then((
                value,
              ) {
                if (value != null && value.isNotEmpty) {
                  toSelect = value;
                  toSelectNotifier.value = value;
                  dPrint("Selected route: $value");
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.secondary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: toSelectNotifier,
                    builder: (context, value, _) {
                      return Text(value, style: AppText.bodyRegular);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [Date Select] widget
  ///
  Widget _dateSelect() {
    final dates = DateUtilsForThirtyDays.getFormattedNextDays();

    return Padding(
      padding: AppSizes.paddingHorizontalMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.secondary,
              ),
              Gap.w8,
              Text("Select Date", style: AppText.smallRegular),
            ],
          ),
          Gap.h8,
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              separatorBuilder: (context, index) => Gap.w8,
              itemBuilder: (context, index) {
                final isSelected = index == selectedDateIndex;

                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      selectedDateIndex = index;
                      final dateString =
                          DateUtilsForThirtyDays.getUtcDateStringFromIndex(
                            index,
                          );
                      dPrint("Date String from index $index: $dateString");
                      selectedDate = dateString;
                      dPrint("Parsed DateTime: $selectedDate");
                    });
                    await _getAvailableShuttles();
                  },

                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color:
                          isSelected
                              ? AppColors.secondary
                              : AppColors.secondary.withAlpha(
                                (0.2 * 255).toInt(),
                              ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dates[index]['day']!,
                            style: AppText.smallRegular.copyWith(
                              color:
                                  isSelected
                                      ? AppColors.background
                                      : AppColors.secondary,
                            ),
                          ),
                          Text(
                            dates[index]['date']!,
                            style: AppText.h2.copyWith(
                              color:
                                  isSelected
                                      ? AppColors.background
                                      : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _availableShuttles() {
    // final availableShuttles = controller.availableShuttlesList;

    return FutureBuilder(
      future: controller.getAvailableShuttles(
        fromSelect,
        toSelect,
        selectedDate,
      ),
      builder: (context, snapshot) {
        // Show loading indicator while data is being fetched
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: AppSizes.paddingAllMedium,
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show error if something went wrong
        if (snapshot.hasError) {
          return Padding(
            padding: AppSizes.paddingHorizontalMedium,
            child: Container(
              decoration: AppDecorations.card,
              child: Padding(
                padding: AppSizes.paddingAllMedium,
                child: Center(
                  child: Text(
                    "Error loading shuttles: ${snapshot.error}",
                    style: AppText.bodyRegular.copyWith(color: AppColors.error),
                  ),
                ),
              ),
            ),
          );
        }

        // Get the data
        final availableShuttles = snapshot.data;

        // Show empty state if no shuttles available
        if (availableShuttles!.isEmpty) {
          return Padding(
            padding: AppSizes.paddingHorizontalMedium,
            child: Container(
              decoration: AppDecorations.card,
              child: Padding(
                padding: AppSizes.paddingAllMedium,
                child: Center(
                  child: Text(
                    "No shuttles available for the selected route and date",
                    style: AppText.bodyRegular.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: AppSizes.paddingHorizontalMedium,
          child: Container(
            decoration: AppDecorations.card,
            child: Column(
              children:
                  availableShuttles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ride = entry.value;
                    final isLastItem = index == availableShuttles.length - 1;

                    // stops and get the first name and last name
                    final stops = ride.bus.stops;
                    final firstStop =
                        stops.isNotEmpty
                            ? stops.first.name.capitalizeFirstOfEach
                            : 'Unknown Stop';
                    final lastStop =
                        stops.isNotEmpty
                            ? stops.last.name.capitalizeFirstOfEach
                            : 'Unknown Stop';

                    // Get the first schedule (or handle multiple schedules if needed)
                    // final firstSchedule =
                    //     ride.schedules ? ride.schedules.first : null;

                    final departureTime = ride.schedules.departureTime;
                    final arrivalTime = ride.schedules.arrivalTime;
                    final timeRange = '$departureTime - $arrivalTime';
                    final date = selectedDate;

                    dPrint("Book a ride Date -? $date");
                    dPrint("Book a ride DEP Date -? $departureTime");

                    // final firstScaduleDate = firstSchedule!.date;

                    // Calculate available seats
                    final availableSeats =
                        ride.bus.seat; // Adjust if you have booking data
                    final seatsText =
                        '$availableSeats ${availableSeats == 1 ? 'seat' : 'seats'} left';

                    final busName =
                        ride.bus.name.isNotEmpty
                            ? ride.bus.name
                            : 'Unknown Bus';

                    return GestureDetector(
                      onTap: () async {
                        try {
                          final data = await controller.getSingleBusDetails(
                            ride.bus.id,
                            firstStop,
                            lastStop,
                            date,
                            departureTime,
                          );

                          NavigationService().sailTo(
                            AppRoutes.busSeats,
                            arguments: {
                              'Seates': data,
                              'source': toSelect,
                              'destination': fromSelect,
                              'date': DateTime.parse(selectedDate),
                              'departureTime': departureTime,
                              'arrivalTime': arrivalTime,
                            },
                          );
                        } catch (e) {
                          dPrint("book a ride screen navite -> $e");
                        }
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            Padding(
                              padding: AppSizes.paddingAllMedium,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// [Soure] to [Destination] Ticket
                                        Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 4, // Equivalent to Gap.w4
                                          runSpacing:
                                              4, // Optional vertical spacing between lines
                                          children: [
                                            Text(
                                              firstStop.capitalizeFirstOfEach,
                                              style: AppText.h3,
                                            ),
                                            ArrowIcon(),
                                            Text(
                                              lastStop.capitalizeFirstOfEach,
                                              style: AppText.h3,
                                            ),
                                          ],
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              timeRange,
                                              style: const TextStyle(
                                                color: AppColors.secondary,
                                              ),
                                            ),
                                            Text(
                                              seatsText,
                                              style: const TextStyle(
                                                color: AppColors.secondary,
                                              ),
                                            ),
                                          ],
                                        ),

                                        Gap.h12,

                                        /// [Bus Name] Shuttle
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              busName.capitalizeFirstLetter(),
                                              style: AppText.smallRegular,
                                            ),
                                            _goldButton(
                                              "Book",
                                              onPressed: () {},
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLastItem) // Only add divider if not the last item
                              Divider(
                                color: AppColors.secondary,
                                height: 16, // Adjust height as needed
                                thickness: 1,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );

    // if (availableShuttles.isEmpty) {
    //   return Padding(
    //     padding: AppSizes.paddingHorizontalMedium,
    //     child: Container(
    //       decoration: AppDecorations.card,
    //       child: Padding(
    //         padding: AppSizes.paddingAllMedium,
    //         child: Center(
    //           child: Text(
    //             "No shuttles available for the selected route and date",
    //             style: AppText.bodyRegular.copyWith(color: AppColors.secondary),
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }
  }

  // Widget _availableShuttles() {
  Widget _goldButton(String text, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 27,
        padding: AppSizes.paddingHorizontalTiny,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Text(
            text,
            style: AppText.bodyMedium.copyWith(color: AppColors.background),
          ),
        ),
      ),
    );
  }
}
