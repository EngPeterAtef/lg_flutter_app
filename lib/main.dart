// main.dart

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liquid Galaxy Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liquid Galaxy Control',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              alignment: Alignment.center,
              child: Image.asset(
                'assets/liquidgalaxylogo.png',
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.height * 0.15,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle reboot LG
                    // Show warning pop-up
                  },
                  child: const Text('Reboot LG'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle move LG to home city
                  },
                  child: const Text('Move LG to Home City'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle make orbit upon arrival
                  },
                  child: const Text('Make Orbit Upon Arrival'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle print HTML bubble
                  },
                  child: const Text('Print HTML Bubble'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Liquid Galaxy Connection User'),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Liquid Galaxy Connection Password'),
              obscureText: true,
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Liquid Galaxy Connection Host Name'),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Liquid Galaxy Connection Port'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Administration Password'),
              obscureText: true,
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Server IP Variable (Advanced)'),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Server Port Variable (Advanced)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
