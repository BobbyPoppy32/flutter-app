import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController controller = TextEditingController();
  bool? isChecked = false;
  bool isSwitched = false;
  double sliderValue = 0.0;
  String? menuItem = "e1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        //automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 5),
                      content: Text("Snackbar"),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(left: 20, bottom: 20),
                    ),
                  );
                },
                child: Text("Open Snackbar"),
              ),


              Divider(
                color: Colors.teal,
                thickness: 5.0,
                endIndent: 200.0 ,
              ),

  

              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context, 
                    builder: (context) {
                      return AlertDialog(
                        alignment: Alignment.centerLeft,
                        title: Text("Alert Title"),
                        content: Text("Alert content"),
                        actions: [
                          FilledButton(
                            onPressed: () {
                            Navigator.pop(context);
                        }, 
                        child: Text("Close"))
                      ],
                    );
                    },
                  );
                },
                child: Text("Open Dialog"),
              ),




              DropdownButton(
                alignment: Alignment.centerLeft,
                value: menuItem,
                items: [
                  DropdownMenuItem(value: "e1", child: Text("Element 1")),

                  DropdownMenuItem(value: "e2", child: Text("Element 2")),

                  DropdownMenuItem(value: "e3", child: Text("Element 3 ")),
                ],
                onChanged: (String? value) {
                  setState(() {
                    menuItem = value;
                  });
                },
              ),

              TextField(
                controller: controller,
                decoration: InputDecoration(border: OutlineInputBorder()),
                onEditingComplete: () {
                  setState(() {});
                },
              ),
              Text(controller.text),



              Checkbox(
                tristate: true,
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value;
                  });
                },
              ),

              CheckboxListTile(
                tristate: true,
                title: Text("Click here"),
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value;
                  });
                },
              ),
              Switch(
                value: isSwitched,
                onChanged: (bool value) {
                  setState(() {
                    isSwitched = value;
                  });
                },
              ),

              SwitchListTile(
                title: Text("Switch here"),
                value: isSwitched,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value;
                  });
                },
              ),
              Slider(
                max: 10.0,
                divisions: 10,
                value: sliderValue,
                onChanged: (double value) {
                  setState(() {
                    sliderValue = value;
                  });
                  print(value);
                },
              ),
              InkWell(
                splashColor: Colors.teal,
                onTap: () {
                  print("image selected");
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  color: Colors.white12,
                ),
              ),

              ElevatedButton(onPressed: () {}, child: Text("Click me")),

              FilledButton(onPressed: () {}, child: Text("Click me")),

              TextButton(onPressed: () {}, child: Text("Click me")),

              OutlinedButton(onPressed: () {}, child: Text("Click me")),
              
              CloseButton(),
              BackButton(),
            ],
          ),
        ),
      ),
    );
  }
}
