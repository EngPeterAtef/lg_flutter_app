// main.dart

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.white,
      primarySwatch: Colors.blue,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 44, 43, 43),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      primaryColorDark: Colors.black,
      primaryColor: Colors.black,
      dialogBackgroundColor: Colors.black,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(const Color.fromARGB(255, 44, 43, 43)),
          textStyle: MaterialStateProperty.all(
            const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      primaryTextTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    // get a bool to know the theme mode of the device
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return MaterialApp(
      title: 'Liquid Galaxy Control',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(isDarkMode: isDarkMode),
    );
  }
}

// ignore: must_be_immutable
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
