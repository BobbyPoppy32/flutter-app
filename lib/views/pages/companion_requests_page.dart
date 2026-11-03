import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/hero_widgets.dart';
import 'package:flutter_app/views/widgets/request_date_format.dart';

class CompanionRequestsPage extends StatelessWidget {
  const CompanionRequestsPage({super.key});

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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeroWidget(title: "Requests"),
                  const SizedBox(height: 20),

                  const SectionHeading("Open Requests"),
                  const SizedBox(height: 10),

                  ValueListenableBuilder(
                    valueListenable: appState.requests,
                    builder: (context, allRequests, child) {
                      final open = appState.openRequestsForCompanions();
                      if (open.isEmpty) {
                        return const EmptyStateCard(message: "No open requests right now, check back soon");
                      }
                      return Column(
                        children: [
                          for (final (i, request) in open.indexed) ...[
                            StaggeredEntrance(
                              index: i,
                              child: _OpenRequestCard(
                                request: request,
                                onAccept: () => _confirmAccept(context, request, user.id, user.name),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  const SectionHeading("My Commitments"),
                  const SizedBox(height: 10),

                  ValueListenableBuilder(
                    valueListenable: appState.requests,
                    builder: (context, allRequests, child) {
                      final commitments = appState.commitmentsForCompanion(user.id);
                      if (commitments.isEmpty) {
                        return const EmptyStateCard(message: "You haven't accepted any requests yet");
                      }
                      return Column(
                        children: [
                          for (final (i, request) in commitments.indexed) ...[
                            StaggeredEntrance(index: i, child: _CommitmentCard(request: request)),
                            const SizedBox(height: 12),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmAccept(BuildContext context, HelpRequest request, String companionId, String companionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Accept this request?"),
        content: Text(
          "Accept this request to help ${request.seniorName} with "
          "${request.taskType.label.toLowerCase()} on ${formatRequestDateTime(request.requestedDateTime)}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Not now"),
          ),
          FilledButton(
            onPressed: () {
              appState.acceptRequest(request.id, companionId: companionId, companionName: companionName);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("You're confirmed to help ${request.seniorName}.")),
              );
            },
            child: const Text("Accept"),
          ),
        ],
      ),
    );
  }
}

class _OpenRequestCard extends StatelessWidget {
  const _OpenRequestCard({required this.request, required this.onAccept});
  final HelpRequest request;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.seniorName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(request.taskType.label, style: const TextStyle(color: AppColors.textGrey)),
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
          if (request.notes != null && request.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(request.notes!, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
          ],
          const SizedBox(height: 14),
          GradientPillButton(label: "Accept", onPressed: onAccept, height: 48),
        ],
      ),
    );
  }
}

class _CommitmentCard extends StatelessWidget {
  const _CommitmentCard({required this.request});
  final HelpRequest request;

  @override
  Widget build(BuildContext context) {
    final isCompleted = request.status == RequestStatus.completed;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.seniorName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                ),
              ),
              StatusPill(
                label: request.status.label,
                color: isCompleted ? AppColors.statusCompleted : AppColors.statusAccepted,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(request.taskType.label, style: const TextStyle(color: AppColors.textGrey)),
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
          if (!isCompleted) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => appState.completeRequest(request.id),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text("Mark as Completed"),
            ),
          ],
        ],
      ),
    );
  }
}
