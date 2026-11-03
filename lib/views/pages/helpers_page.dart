import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/hero_widgets.dart';

/// Real registered companion accounts, browsable by seniors — the honest
/// substitute for the reference mockup's "Recommendations" list. That list
/// showed stock photos and fabricated star ratings; this shows only real
/// account data (name, school/org, availability, background-check status)
/// with a generic avatar rather than implying a real photo exists.
class HelpersPage extends StatelessWidget {
  const HelpersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeroWidget(title: "Helpers", subtitle: "Companions who've signed up to lend a hand"),
              const SizedBox(height: 20),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: appState.currentUser,
                  builder: (context, _, __) {
                    final companions = appState.allCompanions();
                    if (companions.isEmpty) {
                      return const EmptyStateCard(
                        message: "No companions have registered yet — check back soon",
                        icon: Icons.people_outline,
                      );
                    }
                    return ListView.separated(
                      itemCount: companions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => StaggeredEntrance(
                        index: i,
                        child: _HelperCard(companion: companions[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelperCard extends StatelessWidget {
  const _HelperCard({required this.companion});

  final AppUser companion;

  @override
  Widget build(BuildContext context) {
    final verified = companion.backgroundCheckStatus == "Verified";
    return SoftCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconBadge(icon: Icons.person, color: AppColors.tealStart),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(companion.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                const SizedBox(height: 4),
                if (companion.schoolOrOrg != null)
                  Text(companion.schoolOrOrg!, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                if (companion.availabilityNote != null) ...[
                  const SizedBox(height: 2),
                  Text(companion.availabilityNote!, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                ],
                const SizedBox(height: 8),
                StatusPill(
                  label: companion.backgroundCheckStatus ?? "Pending",
                  color: verified ? AppColors.statusCompleted : AppColors.statusOpen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
