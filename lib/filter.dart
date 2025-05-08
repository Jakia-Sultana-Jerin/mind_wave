import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';

class Filterscreen extends StatefulWidget {
  const Filterscreen({super.key});

  @override
  State<Filterscreen> createState() => _FilterState();
}

class _FilterState extends State<Filterscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   appBar: AppBar(title: Text("Filter Screen")),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            opacity: 0.4,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          
          children: [
            Container(
          //    height: 50,

              padding: EdgeInsets.only(top: 25.0),
              
      //        margin: EdgeInsets.all(2),
              decoration: BoxDecoration(color: Colors.white),
              
              child: TextField(
            //    controller: TextEditingController(),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                  hintText: "Search here...."),
                   
              ),
            
            ),
          ],
        ),
      ),
    );
  }

  
}
