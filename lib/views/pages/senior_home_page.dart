import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/pages/request_help_form_page.dart';
import 'package:flutter_app/views/widgets/emergency_contact_card.dart';
import 'package:flutter_app/views/widgets/help_category_grid.dart';
import 'package:flutter_app/views/widgets/hero_widgets.dart';
import 'package:flutter_app/views/widgets/upcoming_request_card.dart';
import 'package:flutter_app/views/widgets/wellness_tip_card.dart';

class SeniorHomePage extends StatelessWidget {
  const SeniorHomePage({super.key});

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
                    subtitle: "Let's get you where you need to go",
                  ),
                  const SizedBox(height: 20),

                  EmergencyContactCard(
                    contactName: user.emergencyContactName,
                    contactPhone: user.emergencyContactPhone,
                    onTap: () => selectedPageNotifier.value = 3,
                  ),
                  const SizedBox(height: 20),

                  ValueListenableBuilder(
                    valueListenable: appState.requests,
                    builder: (context, allRequests, child) {
                      final upcoming = appState
                          .requestsForSenior(user.id)
                          .where((r) => r.status == RequestStatus.open || r.status == RequestStatus.accepted)
                          .toList()
                        ..sort((a, b) => a.requestedDateTime.compareTo(b.requestedDateTime));
                      return UpcomingRequestCard(
                        title: "Your Next Request",
                        request: upcoming.isEmpty ? null : upcoming.first,
                        emptyMessage: "Nothing scheduled — tap a category below to request help",
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Help is Here",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  HelpCategoryGrid(
                    onSelect: (taskType) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestHelpFormPage(initialTaskType: taskType),
                        ),
                      );
                    },
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
