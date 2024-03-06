// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:lg_app/components/connection_flag.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lg_app/connection/ssh.dart';
import 'package:dartssh2/dartssh2.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool connectionStatus = false;
  // Declare SSH Instance
  late SSH ssh;

  Future<void> _connectToLG() async {
    // Connect to Liquid Galaxy Rig
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }

  @override
  void initState() {
    super.initState();
    //Initialize SSH Instance and uncomment _connectToLG()
    ssh = SSH();
    _loadSettings();
    _connectToLG();
  }

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sshPortController = TextEditingController();
  final TextEditingController _rigsController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _sshPortController.dispose();
    _rigsController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('ipAddress') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _sshPortController.text = prefs.getString('sshPort') ?? '';
      _rigsController.text = prefs.getString('numberOfRigs') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_ipController.text.isNotEmpty) {
      await prefs.setString('ipAddress', _ipController.text);
    }
    if (_usernameController.text.isNotEmpty) {
      await prefs.setString('username', _usernameController.text);
    }
    if (_passwordController.text.isNotEmpty) {
      await prefs.setString('password', _passwordController.text);
    }
    if (_sshPortController.text.isNotEmpty) {
      await prefs.setString('sshPort', _sshPortController.text);
    }
    if (_rigsController.text.isNotEmpty) {
      await prefs.setString('numberOfRigs', _rigsController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, connectionStatus);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connection Settings'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () async {
                await Navigator.pushReplacementNamed(context, '/');
                _connectToLG();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ConnectionFlag(
                    status: connectionStatus,
                  )),
              TextField(
                controller: _ipController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.computer),
                  labelText: 'IP address',
                  hintText: 'Enter Master IP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: 'LG Username',
                  hintText: 'Enter your username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'LG Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _sshPortController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.settings_ethernet),
                  labelText: 'SSH Port',
                  hintText: '22',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _rigsController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.memory),
                  labelText: 'No. of LG rigs',
                  hintText: 'Enter the number of rigs',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.green),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                  ),
                ),
                onPressed: () async {
                  await _saveSettings();
                  // Initalize SSH Instance and call connectToLG() function
                  SSH ssh = SSH();
                  bool? result = await ssh.connectToLG();
                  if (result == true) {
                    setState(() {
                      connectionStatus = true;
                    });
                    // await ssh.setLogos();
                    // ignore: use_build_context_synchronously
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      headerAnimationLoop: false,
                      animType: AnimType.bottomSlide,
                      title: 'Success',
                      desc: 'You are not connected to LG.',
                      buttonsTextStyle: const TextStyle(color: Colors.white),
                      showCloseIcon: true,
                      btnCancelOnPress: () {},
                    ).show();
                    debugPrint('Connected to LG successfully');
                  } else {
                    setState(() {
                      connectionStatus = false;
                    });
                    // ignore: use_build_context_synchronously
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      headerAnimationLoop: false,
                      animType: AnimType.bottomSlide,
                      title: 'Error!!!',
                      desc: 'Failed to connect to to LG.',
                      buttonsTextStyle: const TextStyle(color: Colors.white),
                      showCloseIcon: true,
                      // btnCancelOnPress: () {},
                    ).show();
                    debugPrint('Failed to connect to LG');
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cast,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'CONNECT TO LG',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.green),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                  ),
                ),
                onPressed: () async {
                  // Initialize SSH and execute the demo command and test
                  SSH ssh =
                      SSH(); //Re-initialization of the SSH instance to avoid errors for beginners
                  await ssh.connectToLG();
                  SSHSession? execResult =
                      await ssh.execute('echo "search=Lleida" >/tmp/query.txt');
                  if (execResult != null) {
                    debugPrint('Command executed successfully');
                  } else {
                    debugPrint('Failed to execute command');
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cast,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'SEND COMMAND TO LG (Go to Lleida)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Container(
//               margin: const EdgeInsets.all(15),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextFormField(
//                     decoration: const InputDecoration(
//                       labelText: 'Liquid Galaxy Connection User',
//                       labelStyle: TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   TextFormField(
//                     decoration: const InputDecoration(
//                       labelText: 'Liquid Galaxy Connection Password',
//                       labelStyle: TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                     obscureText: true,
//                   ),
//                   TextFormField(
//                     decoration: const InputDecoration(
//                       labelText: 'Liquid Galaxy Connection Host Name',
//                       labelStyle: TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   TextFormField(
//                     decoration: const InputDecoration(
//                       labelText: 'Liquid Galaxy Connection Port',
//                       labelStyle: TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                   TextFormField(
//                     decoration: const InputDecoration(
//                       labelText: 'Administration Password',
//                       labelStyle: TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                     obscureText: true,
//                   ),
//                   TextFormField(
//                     decoration: const InputDecoration(
//                       labelText: 'Server IP Variable (Advanced)',
//                       labelStyle: TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   TextFormField(
//                     decoration: const InputDecoration(
//                       labelText: 'Server Port Variable (Advanced)',
//                       labelStyle: TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ],
//               ),
//             ),
//             // add connect button
//             ElevatedButton(
//               onPressed: () async {
//                 await _saveSettings();
//                 // Initalize SSH Instance and call connectToLG() function
//                 // SSH ssh = SSH();
//                 // bool? result = await ssh.connectToLG();
//                 // if (result == true) {
//                 //   setState(() {
//                 //     connectionStatus = true;
//                 //   });
//                 //   print('Connected to LG successfully');
//                 // }
//               },
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all(Colors.red),
//               ),
//               child: const Text('Connect To LG',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   )),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
