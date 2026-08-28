// Save this to: lib/views/pages/home_page.dart (replaces existing file)

import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/views/widgets/hero_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeroWidget(
                title: "Carely Check",
                subtitle: "Everything you need, all in one place",
              ),
              const SizedBox(height: 20),

              const _EmergencyContactCard(),
              const SizedBox(height: 24),

              const _SectionHeader(title: "Today's Medications"),
              const SizedBox(height: 10),

              const _MedicationReminderCard(
                medicationName: "Aspirin 15mg",
                scheduledTime: "8:00 AM",
                isTaken: true,
              ),
              const SizedBox(height: 10),

              const _MedicationReminderCard(
                medicationName: "High Blood Pressure 30mg",
                scheduledTime: "12:00 PM",
                isTaken: true,
              ),
              const SizedBox(height: 24),

              const _SectionHeader(title: "Next Appointment"),
              const SizedBox(height: 10),
              const _AppointmentCard(
                doctorName: "Dr. Sarah Patel",
                specialty: "Family Medicine",
                date: "Tuesday, April 22",
                time: "10:30 AM",
                location: "Sunview Medical Centre",
              ),
              const SizedBox(height: 24),

              const _SectionHeader(title: "Quick Actions"),
              const SizedBox(height: 10),

              // 2x2 grid of gradient tiles, styled after the reference's
              // "Help is Here" action grid.
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.3,
                children: [
                  _QuickActionTile(
                    icon: Icons.directions_car_filled,
                    label: "Book a Ride",
                    onTap: () {},
                  ),
                  _QuickActionTile(
                    icon: Icons.medication,
                    label: "Add New Med",
                    onTap: () {},
                  ),
                  _QuickActionTile(
                    icon: Icons.calendar_month,
                    label: "Appointments",
                    onTap: () {},
                  ),
                  _QuickActionTile(
                    icon: Icons.phone_in_talk,
                    label: "Call Doctor",
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  const _EmergencyContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.emergencyRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.emergencyRed,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.phone, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Emergency Contact",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.emergencyRed,
                    ),
                  ),
                  Text(
                    "George (Son) · 647-123-4567",
                    style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {},
              child: const Text("Call"),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationReminderCard extends StatelessWidget {
  final String medicationName;
  final String scheduledTime;
  final bool isTaken;

  const _MedicationReminderCard({
    required this.medicationName,
    required this.scheduledTime,
    required this.isTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isTaken ? AppColors.tealStart : Colors.grey,
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicationName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    scheduledTime,
                    style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final String location;

  const _AppointmentCard({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(specialty, style: const TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.tealStart),
                const SizedBox(width: 6),
                Text("$date  •  $time"),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.tealStart),
                const SizedBox(width: 6),
                Expanded(child: Text(location)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.tealStart.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}