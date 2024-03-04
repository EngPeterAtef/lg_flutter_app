// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:lg_app/screens/settings.dart';

class HomeScreen extends StatelessWidget {
  bool isDarkMode;

  HomeScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    // text color
    Color textColor = isDarkMode ? Colors.white : Colors.blue;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liquid Galaxy Control',
        ),
        actions: [
          // add the logo image as button goes to home
          IconButton(
            onPressed: () {
              // Handle go to home
            },
            icon: const Icon(
              Icons.home,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // const CircleAvatar(
            //   backgroundImage: AssetImage(
            //     'assets/liquidgalaxylogo.png',
            //   ),
            //   radius: 100,
            //   backgroundColor: Colors.transparent,
            // ),
            Container(
              // margin: const EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.15,
              alignment: Alignment.center,
              child: Image.asset(
                'assets/liquidgalaxylogo.png',
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle reboot LG
                      // Show warning pop-up
                    },
                    child: Text(
                      'Reboot LG',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle move LG to home city
                    },
                    child: Text(
                      'Move LG to Home City',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle make orbit upon arrival
                    },
                    child: Text(
                      'Make Orbit Upon Arrival',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle print HTML bubble
                    },
                    child: Text(
                      'Print HTML Bubble',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
