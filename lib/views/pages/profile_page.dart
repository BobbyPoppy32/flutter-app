import 'package:flutter/material.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/pages/welcome_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'Your Name';
  String age = 'Age';
  String appointment = 'Appointment';
  String phone = 'Phone Number';
  String address = 'Address';
  String doctor = 'Doctor Name';
  String emergency = 'Emergency Contact';

  void _editField(String label, String current, Function(String) onSave) {
    final controller = TextEditingController(text: current);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => onSave(controller.text));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _profileTile(
    String label,
    String value,
    IconData icon,
    Function(String) onSave, {
    Color tileColor = Colors.white,
    Color iconColor = Colors.lightBlue,
  }) {
    return GestureDetector(
      onTap: () => _editField(label, value, onSave),
      child: Container(
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: iconColor),
            const SizedBox(height: 8),

            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 48,
                color: Colors.lightBlue,
              ),
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: () =>
                  _editField('Name', name, (v) => setState(() => name = v)),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  _profileTile(
                    'Age',
                    age,
                    Icons.cake,
                    (v) => setState(() => age = v),
                  ),

                  const SizedBox(height: 15),

                  _profileTile(
                    'Doctor',
                    doctor,
                    Icons.local_hospital,
                    (v) => setState(() => doctor = v),
                  ),

                  const SizedBox(height: 15),

                  _profileTile(
                    'Emergency Contact',
                    emergency,
                    Icons.emergency,
                    (v) => setState(() => emergency = v),
                    tileColor: Colors.red.shade50,
                    iconColor: Colors.red,
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                selectedPageNotifier.value = 0;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}