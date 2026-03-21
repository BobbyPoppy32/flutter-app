import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/views/widgets/hero_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0), 
      child: SingleChildScrollView(
        child: Column(
          children: [
            HeroWidget(title: "Carely Check"),
            
            
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Title", 
                        style: KTextStytle.titleTealText,
                        
                      ),
                      Text(
                        "Random text",
                        style: KTextStytle.descriptionText,
                      ),
                    ],
                  ),
                ),
              ),
            ),


            Container(
              width: double.infinity,
              padding: EdgeInsets.all(50.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ""
                      ),
                    ],
                    
                  ),
                ),
              ),


            ),
          ],
        ),
      ),
    );
  }
}