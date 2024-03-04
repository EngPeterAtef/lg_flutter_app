import 'package:flutter/material.dart';

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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Liquid Galaxy Connection User',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Liquid Galaxy Connection Password',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    obscureText: true,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Liquid Galaxy Connection Host Name',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Liquid Galaxy Connection Port',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Administration Password',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    obscureText: true,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Server IP Variable (Advanced)',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Server Port Variable (Advanced)',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            // add connect button
            ElevatedButton(
              onPressed: () {
                // Handle connect to LG
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              child: const Text('Connect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
