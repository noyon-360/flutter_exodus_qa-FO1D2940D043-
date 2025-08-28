import 'package:exodus/core/constants/app/app_colors.dart';
import 'package:exodus/core/constants/app/app_gap.dart';
import 'package:exodus/core/constants/app/app_sizes.dart';
import 'package:exodus/core/di/service_locator.dart';
import 'package:exodus/core/network/api_result.dart';
import 'package:exodus/core/network/extensions/either_extensions.dart';
import 'package:exodus/core/services/navigation_service.dart';
import 'package:exodus/core/theme/text_style.dart';
import 'package:exodus/core/utils/debug_logger.dart';
import 'package:exodus/core/utils/snackbar_utils.dart';
import 'package:exodus/presentation/theme/app_styles.dart';
import 'package:exodus/presentation/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/app_state_service.dart';
import '../../../../data/models/payment/payment_response.dart';
import '../controllers/payment_controller.dart';

class BookingSummaryScreen extends StatefulWidget {
  final String busName;
  final String seatNumber;
  final String source;
  final String destination;
  final DateTime date;
  final String departureTime;
  final String arrivalTime;
  final double subtotal;
  final double tax;
  final double total;
  final String ticketId;
  final String reserveBusId;

  const BookingSummaryScreen({
    super.key,
    required this.busName,
    required this.seatNumber,
    required this.source,
    required this.destination,
    required this.date,
    required this.departureTime,
    required this.arrivalTime,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.ticketId,
    required this.reserveBusId,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final PaymentController _paymentController = sl<PaymentController>();
  final AppStateService appStateService = sl<AppStateService>();

  bool _isLoading = false;
  PaymentMethod? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text("Booking Summary", style: AppText.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationService().backtrack(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookingDetails(),
                Gap.h24,
                _buildPriceSummary(),
                Gap.h24,
                _buildPaymentOptions(),
                Gap.h32,
                _buildContinueButton(),
                Gap.bottomAppBarGap,
              ],
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Container(
      decoration: AppDecorations.card,
      child: Padding(
        padding: AppSizes.paddingAllMedium,
        child: Column(
          children: [
            _buildDetailRow(
              Icons.directions_bus_outlined,
              "Bus",
              widget.busName,
            ),
            Gap.h16,
            _buildDetailRow(
              Icons.event_seat_outlined,
              "Seat",
              widget.seatNumber,
            ),
            Gap.h16,
            _buildDetailRow(Icons.location_on_outlined, "From", widget.source),
            Gap.h16,
            _buildDetailRow(
              Icons.location_on_outlined,
              "To",
              widget.destination,
            ),
            Gap.h16,
            _buildDetailRow(
              Icons.calendar_today_outlined,
              "Date",
              DateFormat('EEE, dd MMM yyyy').format(widget.date),
            ),
            Gap.h16,
            _buildDetailRow(
              Icons.access_time_outlined,
              "Time",
              "${widget.departureTime} - ${widget.arrivalTime}",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 20),
        Gap.w12,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppText.smallRegular.copyWith(color: AppColors.secondary),
            ),
            Text(
              value,
              style: AppText.bodyMedium.copyWith(color: AppColors.secondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Subtotal", style: AppText.bodyRegular),
            Text(
              "\$${widget.subtotal.toStringAsFixed(2)}",
              style: AppText.bodyRegular,
            ),
          ],
        ),
        Gap.h12,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Tax", style: AppText.bodyRegular),
            Text(
              "\$${widget.tax.toStringAsFixed(2)}",
              style: AppText.bodyRegular,
            ),
          ],
        ),
        Gap.h12,
        const Divider(color: AppColors.secondary),
        Gap.h12,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total", style: AppText.h3),
            Text("\$${widget.total.toStringAsFixed(2)}", style: AppText.h3),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payment Method", style: AppText.h3),
        Gap.h16,
        _buildPaymentOption(
          "Pay With Stripe",
          PaymentMethod.stripe,
          trailing: Image.asset(
            'assets/icons/stripe_logo.png',
            height: 26,
            width: 40,
          ),
        ),
        Gap.h12,
        _buildPaymentOption("With Subscription", PaymentMethod.subscription),
      ],
    );
  }

  Widget _buildPaymentOption(
    String title,
    PaymentMethod method, {
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: AppSizes.paddingAllMedium,
        decoration: BoxDecoration(
          border: Border.all(
            color:
                _selectedPaymentMethod == method
                    ? AppColors.secondary
                    : Colors.grey.withAlpha((0.3 * 255).toInt()),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      _selectedPaymentMethod == method
                          ? AppColors.secondary
                          : Colors.grey.withAlpha((0.5 * 255).toInt()),
                  width: 2,
                ),
              ),
              child:
                  _selectedPaymentMethod == method
                      ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondary,
                          ),
                        ),
                      )
                      : null,
            ),
            Gap.w12,
            Text(title, style: AppText.bodyRegular),
            const Spacer(),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedPaymentMethod == null ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          "Continue",
          style: AppText.bodyMedium.copyWith(color: AppColors.background),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      _showSnackbar("Please select a payment method");
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      switch (_selectedPaymentMethod) {
        case PaymentMethod.stripe:
          await _processStripePayment();
          break;
        case PaymentMethod.subscription:
          await _processSubscriptionPayment();
          break;
        default:
          _showSnackbar("Invalid payment method");
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar("An error occurred: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _processStripePayment() async {
    try {
      // Create payment intent
      final result = await _paymentController.createPaymentIntent(
        userId: appStateService.currentUser!.user.id,
        ticketId: widget.ticketId,
        reserveBusId: widget.reserveBusId,
        amount: widget.total,
      );

      if (!mounted) return;

      result.handle(
        onSuccess: (data) async {
          dPrint("Result in payment -> ${data.data}");
          final clientSecret = data;

          dPrint("clientSecret -> ${clientSecret}");
          if (mounted) {
            setState(() => _isLoading = false);
          }

          final paymentResult = await _paymentController.processPayment(
            clientSecret: clientSecret.data.transactionId,
          );
          dPrint("Payment result -> $paymentResult");

          paymentResult.fold(
            (failure) {
              if (mounted) {
                _showSnackbar(failure.message);
              }
              return;
            },
            (data) async {
              final confirmResult = await _paymentController.confirmPayment(
                data.data.id,
              );

              if (!mounted) return;
              setState(() => _isLoading = false);

              confirmResult.fold(
                (failure) {
                  _showSnackbar(failure.message);
                  return;
                },
                (data) {
                  _showSnackbar("Payment successful!", isSuccess: true);

                  NavigationService().backtrack();
                },
              );
            },
          );
        },
        onFailure: (failure) {
          if (mounted) {
            _showSnackbar(failure.message);
            setState(() => _isLoading = false);
          }
          return;
        },
      );
    } catch (e) {
      if (mounted) {
        _showSnackbar("Payment failed: ${e.toString()}");
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackbar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    SnackbarUtils.showSnackbar(
      context,
      message: message,
      type: isSuccess ? SnackbarType.success : SnackbarType.error,
    );
  }

  Future<void> _processSubscriptionPayment() async {
    // Implement subscription payment logic
    if (!mounted) return;
    SnackbarUtils.showSnackbar(
      context,
      message: "Subscription payment not implemented yet",
    );
  }
}

enum PaymentMethod { stripe, subscription }
