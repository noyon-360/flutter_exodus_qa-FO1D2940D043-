import 'package:exodus/core/constants/app/app_colors.dart';
import 'package:exodus/core/constants/app/app_gap.dart';
import 'package:exodus/core/constants/app/app_sizes.dart';
import 'package:exodus/core/di/service_locator.dart';
import 'package:exodus/core/routes/app_routes.dart';
import 'package:exodus/core/services/navigation_service.dart';
import 'package:exodus/core/theme/text_style.dart';
import 'package:exodus/core/utils/debug_logger.dart';
import 'package:exodus/core/utils/extensions/string_extensions.dart';
import 'package:exodus/data/models/auth/user_data_response.dart';
import 'package:exodus/data/models/ticket/ticket_model.dart';
import 'package:exodus/presentation/screens/home/controller/home_controller.dart';
import 'package:exodus/presentation/theme/app_styles.dart';
import 'package:exodus/presentation/widgets/arrow_icon_widget.dart';
import 'package:exodus/presentation/widgets/build_title.dart';
import 'package:exodus/presentation/widgets/custom_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = sl<HomeController>();
  // final _rideHistoryController = sl<RideHistoryController>();

  @override
  void initState() {
    super.initState();
    _controller.getUserData();
    // _rideHistoryController.getAllRideHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    // _rideHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          await _controller.getUserData();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Get screen dimensions
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 600;

            return ValueListenableBuilder(
              valueListenable: _controller.userDataNotifier,
              builder: (context, data, child) {
                if (_controller.isLoading) {
                  return Center(child: CircularProgressIndicator.adaptive());
                }
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 0 : screenWidth * 0.1,
                    vertical: 16.0,
                  ),
                  children: [
                    // _buildHeader(value.user),
                    Gap.h16,
                    _buildRideLeftRewardPoints(),

                    Gap.h40,
                    TitleTextWidget(title: "Your Next Ride"),

                    Gap.h16,
                    _buildNextRideCard(data?.ticket ?? List.empty()),

                    Gap.h22,
                    TitleTextWidget(title: "Your All Ride"),

                    Gap.h16,
                    _buildRideList(data?.ticket ?? List.empty()),

                    Gap.bottomAppBarGap,
                  ],
                );
              },
            );

            // return FutureBuilder(
            //   future: _controller.getUserData(),
            //   builder: (context, snapshot) {
            //     // Show loading indicator while waiting for data
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const Center(child: CircularProgressIndicator());
            //     }

            //     // Show error message if something went wrong
            //     // if (snapshot.hasError) {
            //     //   return Center(
            //     //     child: Text(
            //     //       "Failed to load rides: ${snapshot.error}",
            //     //       style: TextStyle(color: AppColors.error),
            //     //     ),
            //     //   );
            //     // }

            //     // dPrint(
            //     //   "Home screen ticket : ${snapshot.data?.ticket.first.price}",
            //     // );
            //   },
            // );

            // ValueListenableBuilder<UserData?>(
            //   valueListenable: _controller.userDataNotifier,

            //   builder: (context, value, _) {
            //     if (value == null) {
            //       return Center(child: CircularProgressIndicator());
            //     }
            //     return ListView(
            //       physics: const BouncingScrollPhysics(),
            //       padding: EdgeInsets.symmetric(
            //         horizontal: isMobile ? 0 : screenWidth * 0.1,
            //         vertical: 16.0,
            //       ),
            //       children: [
            //         // _buildHeader(value.user),
            //         Gap.h16,
            //         _buildRideLeftRewardPoints(),

            //         Gap.h40,
            //         TitleTextWidget(title: "Your Next Ride"),

            //         Gap.h16,
            //         _buildNextRideCard(value.ticket),

            //         Gap.h22,
            //         TitleTextWidget(title: "Your All Ride"),

            //         Gap.h16,
            //         _buildRideList(value.ticket),

            //         Gap.bottomAppBarGap,
            //       ],
            //     );
            //   },
            // );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ValueListenableBuilder<UserData?>(
        valueListenable: _controller.userDataNotifier,
        builder: (context, userData, _) {
          return _controller.isLoading
              ? AppBar()
              : AppBar(
                leadingWidth: 60.0,
                leading: Row(
                  children: [
                    SizedBox(width: 18.0),
                    SizedBox(
                      child: CustomCachedImage.avatarSmall(
                        userData?.user.avatar.url ?? '',
                      ),
                    ),
                  ],
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData?.user.name.capitalizeFirstOfEach ?? 'User Name',
                      style: AppText.bodySemiBold.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      userData?.user.username.startsWithAt ?? "@username",
                      style: AppText.smallRegular,
                    ),
                  ],
                ),
                actions: [
                  InkWell(
                    child: Icon(
                      Icons.notifications_none_outlined,
                      color: AppColors.secondary,
                    ),
                    onTap: () {
                      NavigationService().sailTo(AppRoutes.notification);
                    },
                  ),
                  SizedBox(width: 18.0),
                ],
              );
        },
      ),
    );
  }

  Widget _buildRideLeftRewardPoints() {
    return Padding(
      padding: AppSizes.paddingHorizontalExtraMedium,
      child: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _controller.rideLeft,
              builder: (context, value, child) {
                return _buildStatsCard("Ride Left", value.toString());
              },
            ),
          ),
          Gap.w16,
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _controller.rewardPoint,
              builder: (context, value, child) {
                return _buildStatsCard("Reward Points", value.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildHeader(User user) {
  //   dPrint("user Image -> ${user.avatar.url}");
  //   return Padding(
  //     padding: AppSizes.paddingHorizontalExtraMedium,
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // CustomCachedImage.avatarSmall(user.avatar.url),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text("Hello, ${user.name}"),
  //               SizedBox(height: 4),
  //               Text("@${user.username}", style: TextStyle()),
  //             ],
  //           ),
  //         ),
  //         Icon(
  //           Icons.notifications_none_outlined,
  //           color: AppColors.secondary,
  //           size: 28,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildTitle(String title) {
  //   return Padding(
  //     padding: AppSizes.paddingHorizontalExtraMedium,
  //     child: Text(title, style: AppText.bodySemiBold),
  //   );
  // }

  Widget _buildStatsCard(String title, String value) {
    return Container(
      padding: AppSizes.paddingAllRegular,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: AppSizes.borderRadiusMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.h3.copyWith(color: AppColors.buttonText)),
          Gap.h4,
          Text(value, style: AppText.h1.copyWith(color: AppColors.buttonText)),
        ],
      ),
    );
  }

  Widget _buildNextRideCard(List<TicketModel> tickets) {
    if (tickets.isEmpty) {
      return Padding(
        padding: AppSizes.paddingAllRegular,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppSizes.borderRadiusMedium,
            border: Border.all(color: AppColors.secondary),
          ),
          padding: AppSizes.paddingAllRegular,
          child: const Center(child: Text("No upcoming rides")),
        ),
      );
    }

    // Only take the first ticket
    final ticket = tickets.last;

    return GestureDetector(
      onTap:
          () => NavigationService().sailTo(
            AppRoutes.rideDetails,
            arguments: {
              'Tickets': [ticket],
            },
          ),
      // Navigator.pushNamed(
      //   context,
      //   AppRoutes.rideDetails,
      //   arguments: {
      //     'Tickets': [ticket],
      //   },
      // ),
      child: Padding(
        padding: AppSizes.paddingHorizontalExtraMedium.copyWith(bottom: 16),
        child: Container(
          decoration: AppDecorations.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Source -> Destination & Date
              Container(
                padding: AppSizes.paddingAllRegular,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              ticket.source,
                              style: AppText.h3.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Gap.w4,
                            ArrowIcon(color: AppColors.background),
                            Gap.w4,
                            Text(
                              ticket.destination,
                              style: AppText.h3.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('EEE, MMM d').format(ticket.date),
                      style: AppText.bodySemiBold.copyWith(
                        color: AppColors.background,
                      ),
                    ),
                  ],
                ),
              ),

              // Body: Ride Info
              Padding(
                padding: AppSizes.paddingAllRegular,
                child: Column(
                  children: [
                    _rideInfoRow(Icons.directions_bus, "Bus", ticket.bus.busNumber),
                    Gap.h16,
                    _rideInfoRow(Icons.event_seat, "Seat", ticket.seatNumber),
                    Gap.h16,
                    _rideInfoRow(Icons.access_time, "Time", ticket.time),
                    Gap.h24,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _goldButton(ticket.status),
                        Row(
                          children: [
                            Text("View Details", style: AppText.smallRegular),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: AppColors.secondary,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Widget _buildNextRideCard(List<TicketModel> tickets) {
  //   // Find the next upcoming ticket (you might want to add proper logic here)
  //   final nextTicket = tickets.isNotEmpty ? tickets.first : null;

  //   if (nextTicket == null) {
  //     return Padding(
  //       padding: AppSizes.paddingAllRegular,
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: AppColors.background,
  //           borderRadius: AppSizes.borderRadiusMedium,
  //           border: Border.all(color: AppColors.secondary),
  //         ),
  //         padding: AppSizes.paddingAllRegular,
  //         child: const Center(child: Text("No upcoming rides")),
  //       ),
  //     );
  //   }

  //   return GestureDetector(
  //     onTap:
  //         () => Navigator.pushNamed(
  //           context,
  //           AppRoutes.rideDetails,
  //           arguments: {'Tickets': tickets},
  //         ),
  //     child: Padding(
  //       padding: AppSizes.paddingHorizontalExtraMedium,
  //       child: Container(
  //         decoration: AppDecorations.card,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Container(
  //               padding: AppSizes.paddingAllRegular,
  //               decoration: const BoxDecoration(
  //                 color: AppColors.secondary,
  //                 borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   /// [Soure] to [Destination] Ticket
  //                   Row(
  //                     children: [
  //                       Wrap(
  //                         crossAxisAlignment: WrapCrossAlignment.center,
  //                         children: [
  //                           Text(
  //                             nextTicket.source,
  //                             style: AppText.h3.copyWith(
  //                               color: AppColors.background,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                           Gap.w4,

  //                           /// [Arrow] Icon
  //                           ArrowIcon(color: AppColors.background),

  //                           Gap.w4,
  //                           Text(
  //                             nextTicket.destination,
  //                             style: AppText.h3.copyWith(
  //                               color: AppColors.background,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),

  //                   /// [Date]
  //                   Text(
  //                     DateFormat('EEE, MMM d').format(nextTicket.date),
  //                     style: AppText.bodySemiBold.copyWith(
  //                       color: AppColors.background,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Padding(
  //               padding: AppSizes.paddingAllRegular,
  //               child: Column(
  //                 children: [
  //                   // Gap.h12,
  //                   _rideInfoRow(
  //                     Icons.directions_bus,
  //                     "Bus",
  //                     nextTicket.busNumber,
  //                   ),
  //                   Gap.h16,
  //                   _rideInfoRow(
  //                     Icons.event_seat,
  //                     "Seat",
  //                     nextTicket.seatNumber,
  //                   ),
  //                   Gap.h16,
  //                   _rideInfoRow(Icons.access_time, "Time", nextTicket.time),
  //                   // if (nextTicket.qrCode.isNotEmpty) ...[
  //                   //   const SizedBox(height: 12),
  //                   //   Center(
  //                   //     child: Image.network(nextTicket.qrCode, height: 100, width: 100),
  //                   //   ),
  //                   // ],
  //                   Gap.h24,
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       _goldButton(nextTicket.status),
  //                       Row(
  //                         children: [
  //                           Text("View Details", style: AppText.smallRegular),
  //                           SizedBox(width: 4),
  //                           Icon(
  //                             Icons.arrow_forward,
  //                             color: AppColors.secondary,
  //                             size: 16,
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _rideInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.secondary, size: 20),
        Gap.w8,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.smallRegular),
            Text(value, style: AppText.bodyMedium),
          ],
        ),
      ],
    );
  }

  Widget _goldButton(String text) {
    return Container(
      padding: AppSizes.paddingAllSmall,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: AppColors.primaryGradient,
      ),
      child: Text(
        text.capitalizeFirstLetter(),
        style: AppText.tinyRegular.copyWith(color: AppColors.background),
      ),
    );
  }

  // Widget _buildAllRidesList() {
  //   return Padding(
  //     padding: AppSizes.paddingHorizontalExtraMedium,
  //     child: FutureBuilder<List<TicketModel>>(
  //       future: _rideHistoryController.getAllRideHistory(),
  //       builder: (context, snapshot) {
  //         // Show loading indicator while waiting for data
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(child: CircularProgressIndicator());
  //         }

  //         // Show error message if something went wrong
  //         if (snapshot.hasError) {
  //           return Center(
  //             child: Text(
  //               "Failed to load rides: ${snapshot.error}",
  //               style: TextStyle(color: AppColors.error),
  //             ),
  //           );
  //         }

  //         // Get all rides without filtering
  //         final rides = snapshot.data ?? [];

  //         // Show empty state if no rides
  //         if (rides.isEmpty) {
  //           return Center(
  //             child: Text("No rides found", style: AppText.bodyMedium),
  //           );
  //         }

  //         // return SizedBox(child: Text("Data -> ${rides.first.busNumber}"));

  //         // Display all rides
  //         return _buildRideList(rides);
  //       },
  //     ),
  //   );
  // }

  Widget _buildRideList(List<TicketModel> rides) {
    if (rides.isEmpty) {
      return SizedBox.shrink();
    }
    // Show only up to 4 rides
    final displayRides = rides.length > 4 ? rides.sublist(0, 4) : rides;

    return Padding(
      padding: AppSizes.paddingHorizontalExtraMedium,
      child: Container(
        decoration: AppDecorations.card,
        child: ListView.builder(
          key: ValueKey(displayRides.length),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: displayRides.length,
          itemBuilder: (context, index) {
            final ride = displayRides[index];
            return GestureDetector(
              onTap:
                  () => NavigationService().sailTo(
                    AppRoutes.rideDetails,
                    arguments: {
                      'Tickets': [ride],
                    },
                  ),
              child: Container(
                color: AppColors.background,
                child: _buildRideCard(ride, index == displayRides.length - 1),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRideCard(TicketModel ride, bool isLastItem) {
    // Color statusColor;
    // IconData statusIcon;

    // switch (ride.status.toLowerCase()) {
    //   case 'completed':
    //     statusColor = AppColors.success;
    //     statusIcon = Icons.check_circle;
    //     break;
    //   case 'canceled':
    //     statusColor = AppColors.error;
    //     statusIcon = Icons.cancel;
    //     break;
    //   default:
    //     statusColor = Colors.blue;
    //     statusIcon = Icons.access_time;
    // }

    return Column(
      children: [
        Padding(
          padding: AppSizes.paddingAllMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  /// [Soure] to [Destination] Ticket
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4, // Equivalent to Gap.w4
                    runSpacing: 4, // Optional vertical spacing between lines
                    children: [
                      Text(ride.source, style: AppText.h3),
                      ArrowIcon(),
                      Text(ride.destination, style: AppText.h3),
                    ],
                  ),
                  // Text(
                  //   '${ride.source} to ${ride.destination}',
                  //   style: const TextStyle(
                  //     color: AppColors.secondary,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 16,
                  //   ),
                  // ),
                  // const Spacer(),
                  // Row(
                  //   children: [
                  //     Icon(statusIcon, color: statusColor, size: 14),
                  //     const SizedBox(width: 4),
                  //     Text(ride.status, style: TextStyle(color: statusColor)),
                  //   ],
                  // ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ride.time,
                style: const TextStyle(color: AppColors.secondary),
              ),
              const SizedBox(height: 4),
              Gap.h12,

              /// [Bus Name] Shuttle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("Appple Red Bus", style: AppText.smallRegular)],
              ),
            ],
          ),
        ),
        if (!isLastItem) const Divider(height: 16, color: AppColors.secondary),
      ],
    );
  }
}
