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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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

  Widget _profileTile(String label, String value, IconData icon, Function(String) onSave) {
    return GestureDetector(
      onTap: () => _editField(label, value, onSave),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: Colors.teal),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.teal,
            child: Icon(Icons.person, size: 45, color: Colors.white),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _editField('Name', name, (v) => setState(() => name = v)),
            child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _profileTile('Age', age, Icons.cake, (v) => age = v),
                _profileTile('Phone', phone, Icons.phone, (v) => phone = v),
                _profileTile('Appointments', appointment, Icons.calendar_today, (v) => appointment = v),
                _profileTile('Address', address, Icons.home, (v) => address = v),
                _profileTile('Doctor', doctor, Icons.local_hospital, (v) => doctor = v),
                _profileTile('Emergency Contact', emergency, Icons.emergency, (v) => emergency = v),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            onTap: () {
              selectedPageNotifier.value = 0;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WelcomePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}