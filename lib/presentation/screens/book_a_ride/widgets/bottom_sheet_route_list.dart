import 'package:exodus/core/constants/app/app_colors.dart';
import 'package:exodus/core/services/navigation_service.dart';
import 'package:exodus/core/theme/text_style.dart';
import 'package:flutter/material.dart';

Future<String?> showLocationBottomSheet(
  BuildContext context,
  List<String> routes,
) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return routes.isEmpty
          ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
          : SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                return ListTile(
                  title: Text(route, style: AppText.bodyMedium),
                  onTap: () {
                    // NavigationService().sailTo(route);
                    Navigator.pop(context, route);
                  },
                );
              },
              separatorBuilder: (_, __) => Divider(color: AppColors.secondary),
            ),
          );
    },
  );
}
