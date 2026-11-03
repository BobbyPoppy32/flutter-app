import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/hero_widgets.dart';
import 'package:flutter_app/views/widgets/upcoming_request_card.dart';
import 'package:flutter_app/views/widgets/wellness_tip_card.dart';

class CompanionHomePage extends StatelessWidget {
  const CompanionHomePage({super.key});

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
                  HeroWidget(
                    title: "Hi, ${user.name}",
                    subtitle: "See who needs a hand nearby",
                  ),
                  const SizedBox(height: 20),

                  ValueListenableBuilder(
                    valueListenable: appState.requests,
                    builder: (context, allRequests, child) {
                      final open = appState.openRequestsForCompanions();
                      final commitments = appState.commitmentsForCompanion(user.id)
                        ..removeWhere((r) => r.status == RequestStatus.completed || r.status == RequestStatus.cancelled);
                      return Row(
                        children: [
                          Expanded(child: _StatTile(label: "Open Requests", count: open.length, icon: Icons.inbox_outlined)),
                          const SizedBox(width: 14),
                          Expanded(child: _StatTile(label: "My Commitments", count: commitments.length, icon: Icons.volunteer_activism_outlined)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  ValueListenableBuilder(
                    valueListenable: appState.requests,
                    builder: (context, allRequests, child) {
                      final commitments = appState.commitmentsForCompanion(user.id)
                        ..removeWhere((r) => r.status == RequestStatus.completed || r.status == RequestStatus.cancelled)
                        ..sort((a, b) => a.requestedDateTime.compareTo(b.requestedDateTime));
                      return UpcomingRequestCard(
                        title: "Your Next Commitment",
                        request: commitments.isEmpty ? null : commitments.first,
                        emptyMessage: "No commitments yet — check Requests for people who need a hand",
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  GradientPillButton(
                    label: "Browse Requests",
                    icon: Icons.search_rounded,
                    height: 56,
                    onPressed: () => selectedPageNotifier.value = 1,
                  ),
                  const SizedBox(height: 20),

                  const WellnessTipCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.count, required this.icon});

  final String label;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.tealStart, size: 22),
          const SizedBox(height: 10),
          Text("$count", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
        ],
      ),
    );
  }
}
