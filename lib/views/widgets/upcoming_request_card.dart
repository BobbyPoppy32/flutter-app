import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/request_date_format.dart';
import 'package:flutter_app/views/widgets/task_type_icons.dart';

/// A "next up" summary card driven by real request data — the honest
/// substitute for the reference mockup's heart-rate widget. That widget
/// implied live vitals monitoring this app has no sensor/device access to
/// provide; fabricating a number would be misleading, especially in a
/// health-adjacent app for seniors. This shows something real instead.
class UpcomingRequestCard extends StatelessWidget {
  const UpcomingRequestCard({super.key, required this.title, required this.request, required this.emptyMessage});

  final String title;
  final HelpRequest? request;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (request == null) {
      return SoftCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const IconBadge(icon: Icons.event_available_outlined, color: AppColors.tealStart),
            const SizedBox(width: 14),
            Expanded(
              child: Text(emptyMessage, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
            ),
          ],
        ),
      );
    }

    final r = request!;
    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          IconBadge(icon: iconForTaskType(r.taskType), color: AppColors.tealStart),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textGrey)),
                const SizedBox(height: 4),
                Text(r.taskType.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(
                  "${formatRequestDateTime(r.requestedDateTime)} · ${r.locationText}",
                  style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
