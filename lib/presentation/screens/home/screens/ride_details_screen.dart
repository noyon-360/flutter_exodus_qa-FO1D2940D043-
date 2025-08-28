import 'dart:convert';
import 'dart:typed_data';

import 'package:exodus/core/di/service_locator.dart';
import 'package:exodus/core/routes/app_routes.dart';
import 'package:exodus/core/services/navigation_service.dart';

import 'package:exodus/core/utils/extensions/button_extensions.dart';
import 'package:exodus/data/models/ticket/ticket_model.dart';
import 'package:exodus/presentation/screens/book_a_ride/controllers/create_ticket_controller.dart';
import 'package:exodus/presentation/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app/app_colors.dart';
import '../../../../core/constants/app/app_gap.dart';
import '../../../../core/constants/app/app_sizes.dart';
import '../../../../core/theme/text_style.dart';

class RideDetailsScreen extends StatefulWidget {
  final List<TicketModel> tickets;
  const RideDetailsScreen({super.key, required this.tickets});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  final controller = sl<CreateTicketController>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile layout
          return Scaffold(
            appBar: AppBar(title: Text("Ride Details")),
            body: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildNextRideCard(widget.tickets),

                Gap.h22,
                _buildTitle("Your Next Ride"),

                Gap.h22,
                _buildQRcode(widget.tickets),

                Gap.h22,
                _cancellationPolicy(context, widget.tickets),
              ],
            ),
          );
        } else {
          // Tablet/Desktop layout
          return Scaffold(
            appBar: AppBar(title: Text("Ride Details")),
            body: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ListView(
                    children: [_buildNextRideCard(widget.tickets)],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      "Additional Details or Placeholder",
                      style: AppText.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildNextRideCard(List<TicketModel> tickets) {
    // Find the next upcoming ticket (you might want to add proper logic here)
    final nextTicket = tickets.isNotEmpty ? tickets.first : null;

    if (nextTicket == null) {
      return Padding(
        padding: AppSizes.paddingAllExtraMedium,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppSizes.borderRadiusMedium,
          ),
          padding: AppSizes.paddingAllRegular,
          child: const Center(
            child: Text(
              "No upcoming rides",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        decoration: AppDecorations.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: AppSizes.paddingAllExtraMedium,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// [Soure] to [Destination] Ticket
                  Row(
                    children: [
                      Text(
                        nextTicket.source,
                        style: AppText.h3.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap.w4,
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.background,
                        size: 20,
                      ),
                      Gap.w4,
                      Text(
                        nextTicket.destination,
                        style: AppText.h3.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  /// [Date]
                  Text(
                    DateFormat('EEE, MMM d').format(nextTicket.date),
                    style: AppText.bodySemiBold.copyWith(
                      color: AppColors.background,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppSizes.paddingAllExtraMedium,
              child: Column(
                children: [
                  // Gap.h12,
                  _rideInfoRow(
                    Icons.directions_bus,
                    "Bus",
                    nextTicket.bus.busNumber,
                  ),
                  Gap.h18,
                  _rideInfoRow(Icons.event_seat, "Seat", nextTicket.seatNumber),
                  Gap.h16,
                  _rideInfoRow(
                    Icons.access_time_filled,
                    "Time",
                    nextTicket.time,
                  ),
                  Gap.h16,
                  _rideInfoRow(
                    Icons.edit_location_alt_rounded,
                    "Status",
                    nextTicket.status,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      child: Row(
        children: [
          Text(
            text,
            style: AppText.tinyRegular.copyWith(color: AppColors.background),
          ),
          Gap.w8,
          SizedBox(
            height: 18,
            width: 18,
            child: Image.asset("assets/icons/location_round.png"),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: AppSizes.paddingHorizontalExtraMedium,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppText.bodySemiBold),
          GestureDetector(
            onTap:
                () => NavigationService().sailTo(
                  AppRoutes.map,
                  arguments: {
                    'Tickets': [widget.tickets.first],
                  },
                ),
            child: _goldButton("See Map"),
          ),
        ],
      ),
    );
  }

  Widget _buildQRcode(List<TicketModel> tickets) {
    // Extract base64 data by removing the prefix
    final String base64String = tickets.first.qrCode!.split(',').last;
    final Uint8List bytes = base64Decode(base64String);

    return Padding(
      padding: AppSizes.paddingHorizontalExtraMedium,
      child: Container(
        decoration: AppDecorations.card,
        child: Padding(
          padding: AppSizes.paddingAllMedium,
          child: Column(
            children: [
              Text(
                "Scan this QR code when boarding and exiting the shuttle",
                style: AppText.bodyRegular,
              ),

              Gap.h16,
              Image.memory(bytes, width: 240, height: 240, fit: BoxFit.contain),

              Gap.h16,

              ///`?` [Todo : The ticket Ride ID]
              Text(
                "Ride ID: ${tickets.first.id.substring(0, 4)}",
                style: AppText.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cancellationPolicy(BuildContext context, List<TicketModel> tickets) {
    return Padding(
      padding: AppSizes.paddingAllExtraMedium,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.containerPolicyColor,
          borderRadius: AppSizes.borderRadiusMedium,
        ),
        child: Padding(
          padding: AppSizes.paddingAllMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// [Title]
              Text("Cancellation Policy", style: AppText.bodyMedium),

              Gap.h8,
              Text(
                "You can cancel this ride up to 4 hours before departure without penalty. Cancellations within 15 minutes of departure will incur a penalty fee. ",
              ),

              Gap.h16,
              context.secondaryButton(
                onPressed: () async {
                  await controller.cancelTicket(tickets.first.id);
                },
                widget: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback:
                          (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                    Gap.w12,
                    ShaderMask(
                      shaderCallback:
                          (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        "Cancel Ride",
                        style: AppText.smallMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
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
}
