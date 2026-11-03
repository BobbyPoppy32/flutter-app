import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/hero_widgets.dart';
import 'package:flutter_app/views/widgets/request_date_format.dart';

class SeniorRequestsPage extends StatelessWidget {
  const SeniorRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: ValueListenableBuilder(
        valueListenable: appState.currentUser,
        builder: (context, user, child) {
          if (user == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeroWidget(title: "My Requests"),
                const SizedBox(height: 20),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: appState.requests,
                    builder: (context, allRequests, child) {
                      final myRequests = appState.requestsForSenior(user.id);
                      if (myRequests.isEmpty) {
                        return const EmptyStateCard(message: "You have no requests yet");
                      }
                      return ListView.separated(
                        itemCount: myRequests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => StaggeredEntrance(
                          index: i,
                          child: _MyRequestCard(request: myRequests[i]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MyRequestCard extends StatelessWidget {
  const _MyRequestCard({required this.request});
  final HelpRequest request;

  Color get _statusColor {
    switch (request.status) {
      case RequestStatus.open:
        return AppColors.statusOpen;
      case RequestStatus.accepted:
        return AppColors.statusAccepted;
      case RequestStatus.completed:
        return AppColors.statusCompleted;
      case RequestStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  bool get _canCancel => request.status == RequestStatus.open || request.status == RequestStatus.accepted;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.taskType.label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                ),
              ),
              StatusPill(label: request.status.label, color: _statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: AppColors.tealStart),
              const SizedBox(width: 6),
              Text(formatRequestDateTime(request.requestedDateTime)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.tealStart),
              const SizedBox(width: 6),
              Expanded(child: Text(request.locationText)),
            ],
          ),
          if (request.acceptedByCompanionName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.tealStart),
                const SizedBox(width: 6),
                Text("Accepted by ${request.acceptedByCompanionName}"),
              ],
            ),
          ],
          if (_canCancel) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _confirmCancel(context),
                style: TextButton.styleFrom(foregroundColor: AppColors.emergencyRed),
                child: const Text("Cancel"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel this request?"),
        content: Text("This will cancel your ${request.taskType.label.toLowerCase()} request."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Keep it"),
          ),
          TextButton(
            onPressed: () {
              appState.cancelRequest(request.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.emergencyRed),
            child: const Text("Cancel request"),
          ),
        ],
      ),
    );
  }
}
