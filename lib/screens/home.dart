import 'package:flutter/material.dart';
import 'package:lg_app/components/connection_flag.dart';
import 'package:lg_app/connection/ssh.dart';
import '../components/card.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:lg_app/models/orbit.dart';
// import 'package:flutter_bounceable/flutter_bounceable.dart';

bool connectionStatus = false;
bool tourStatus = true;
// Initialize const String searchPlace
const String searchPlace = 'Giza';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Initialize SSH instance just like you did in the settings_page.dart, just uncomment the lines below,
  // this time use the same instance for each of the tasks
  late SSH ssh;

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _connectToLG();
    ssh.setRefresh();
  }
  // call the _connectToLG() method every time you opens the sceen

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LG Connection'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushReplacementNamed(context, '/settings');
              _connectToLG();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
              child: ConnectionFlag(
                status: connectionStatus,
              )),
          Container(
            // margin: const EdgeInsets.all(15),
            width: MediaQuery.of(context).size.width * 0.15,
            height: MediaQuery.of(context).size.height * 0.15,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/liquidgalaxylogo.png',
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ReusableCard(
                    colour: Colors.grey,
                    onPress: () async {
                      // Implement relaunchLG() as async task
                      if (connectionStatus == true) {
                        await ssh.relaunch();
                      } else {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          headerAnimationLoop: false,
                          animType: AnimType.bottomSlide,
                          title: 'Error!!!',
                          desc: 'You are not connected to LG.',
                          buttonsTextStyle:
                              const TextStyle(color: Colors.white),
                          showCloseIcon: true,
                          btnCancelOnPress: () {},
                        ).show();
                      }
                    },
                    cardChild: const Center(
                      child: Text(
                        'RELAUNCH LG',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ReusableCard(
                    colour: Colors.grey,
                    onPress: () async {
                      // Implement shutdownLG() as async task
                      if (connectionStatus == true) {
                        await ssh.shutdown();
                      } else {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          headerAnimationLoop: false,
                          animType: AnimType.bottomSlide,
                          title: 'Error!!!',
                          desc: 'You are not connected to LG.',
                          buttonsTextStyle:
                              const TextStyle(color: Colors.white),
                          showCloseIcon: true,
                          btnCancelOnPress: () {},
                        ).show();
                      }
                    },
                    cardChild: const Center(
                      child: Text(
                        'SHUT DOWN LG',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ReusableCard(
                    colour: Colors.grey,
                    onPress: () async {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        headerAnimationLoop: false,
                        animType: AnimType.bottomSlide,
                        title: 'Do you want to reboot the LG rig?',
                        desc:
                            'This will switch off the current session of the rig and reboot the machine',
                        buttonsTextStyle: const TextStyle(color: Colors.white),
                        showCloseIcon: true,
                        btnCancelOnPress: () {},
                        btnOkOnPress: () async {
                          if (connectionStatus == true) {
                            await ssh.reboot();
                          } else {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              headerAnimationLoop: false,
                              animType: AnimType.bottomSlide,
                              title: 'Error!!!',
                              desc: 'You are not connected to LG.',
                              buttonsTextStyle:
                                  const TextStyle(color: Colors.white),
                              showCloseIcon: true,
                              btnCancelOnPress: () {},
                            ).show();
                          }
                        },
                      ).show();
                    },
                    cardChild: const Center(
                      child: Text(
                        'REBOOT LG',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ReusableCard(
                    colour: Colors.grey,
                    onPress: () async {
                      // Implement searchPlace(String searchPlace) as async task and test
                      ssh.searchPlace(searchPlace);
                    },
                    cardChild: const Center(
                      child: Text(
                        // Add searchPlace variable to the button
                        'SEARCH = $searchPlace',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                // Expanded(
                //   child: ReusableCard(
                //     colour: Colors.grey,
                //     onPress: () async {
                //       // Implement startOrbit
                //       ssh.startOrbit();
                //     },
                //     cardChild: const Center(
                //       child: Text(
                //         "Start Orbit!",
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 40,
                //           fontWeight: FontWeight.w700,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // Expanded(
                //   child: ReusableCard(
                //     colour: Colors.grey,
                //     onPress: () async {
                //       ssh.stopOrbit();
                //     },
                //     cardChild: const Center(
                //       child: Text(
                //         "Stop Orbit!",
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 40,
                //           fontWeight: FontWeight.w700,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Expanded(
                  child: ReusableCard(
                    colour: Colors.grey,
                    onPress: () async {
                      if (connectionStatus == true) {
                        // Implement buildOrbit() as async task
                        if (!tourStatus) {
                          await ssh.stopOrbit();
                        } else {
                          await SSH().buildOrbit(
                              Orbit.buildOrbit(Orbit.generateOrbitTag()));
                          debugPrint("Orbit built successfully!");
                          // await ssh.startOrbit();
                          // debugPrint("Orbit started successfully!");
                        }
                        setState(() {
                          tourStatus = !tourStatus;
                        });
                      } else {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          headerAnimationLoop: false,
                          animType: AnimType.bottomSlide,
                          title: 'Error!!!',
                          desc: 'You are not connected to LG.',
                          buttonsTextStyle:
                              const TextStyle(color: Colors.white),
                          showCloseIcon: true,
                          btnCancelOnPress: () {},
                        ).show();
                      }
                    },
                    cardChild: Center(
                      child: Text(
                        tourStatus ? 'Start a Tour!' : 'End the Tour!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ReusableCard(
                    colour: Colors.grey,
                    onPress: () async {
                      // Implement sendKML() as async task

                      if (connectionStatus == true) {
                        // await ssh.openBalloon("Giza", "Giza", "Peter Atef", 240,
                        //     "Giza is a city in Egypt. It is located on the west bank of the Nile River, some 20 kilometers (12 miles) southwest of central Cairo. Along with Shubra El-Kheima, Cairo, and Helwan, the four cities form the Province of Greater Cairo metropolis. Giza is the third-largest city in Egypt and the second-largest in Greater Cairo, after Cairo. It is also the second-largest city in North Africa. Its population was 3,628,062 in the 2006 national census, while the governorate had 6,272,571 at the same census. It is the city of the Giza Governorate, and is located in the northeast of this governorate, near its border. The city is located on the west bank of the Nile, near the old town of Memphis. The city's population was 2,681,863 in the 2006 national census, while the governorate had 6,272,571 at the same census.");
                        // await ssh.runKml("Giza");
                        await ssh.setLogos();
                        await ssh.buildBallon();
                      } else {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          headerAnimationLoop: false,
                          animType: AnimType.bottomSlide,
                          title: 'Error!!!',
                          desc: 'You are not connected to LG.',
                          buttonsTextStyle:
                              const TextStyle(color: Colors.white),
                          showCloseIcon: true,
                          btnCancelOnPress: () {},
                        ).show();
                      }
                    },
                    cardChild: const Center(
                      child: Text(
                        'SEND KML',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ReusableCard(
                    colour: Colors.grey,
                    onPress: () async {
                      // Implement clearKML() as async task and test
                      if (connectionStatus == true) {
                        await ssh.clearKml();
                        await ssh.setRefresh();
                        // await ssh.clearBalloon();
                        // await ssh.cleanKML();
                        debugPrint('KML Cleared');
                      } else {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          headerAnimationLoop: false,
                          animType: AnimType.bottomSlide,
                          title: 'Error!!!',
                          desc: 'You are not connected to LG.',
                          buttonsTextStyle:
                              const TextStyle(color: Colors.white),
                          showCloseIcon: true,
                          btnCancelOnPress: () {},
                        ).show();
                      }
                    },
                    cardChild: const Center(
                      child: Text(
                        'CLEAN KML',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                // Expanded(
                //   child: ReusableCard(
                //     colour: Colors.grey,
                //     onPress: () async {
                //       // Implement searchPlace(String searchPlace) as async task and test
                //       ssh.stopOrbit();
                //     },
                //     cardChild: const Center(
                //       child: Text(
                //         // Add searchPlace variable to the button
                //         ,
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 40,
                //           fontWeight: FontWeight.w700,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: must_be_immutable

// import 'package:flutter/material.dart';
// import 'package:lg_app/screens/settings.dart';
// import 'package:lg_app/components/connection_flag.dart';

// bool connectionStatus = false;

// class HomeScreen extends StatefulWidget {
//   bool isDarkMode;

//   HomeScreen({super.key, required this.isDarkMode});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     // text color
//     Color textColor = widget.isDarkMode ? Colors.white : Colors.blue;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Liquid Galaxy Controller',
//         ),
//         actions: [
//           // add the logo image as button goes to home
//           IconButton(
//             onPressed: () {
//               // Handle go to home
//             },
//             icon: const Icon(
//               Icons.home,
//               color: Colors.white,
//             ),
//           ),
//           IconButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const SettingsPage(),
//                 ),
//               );
//             },
//             icon: const Icon(
//               Icons.settings,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignmentaceAround,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // const CircleAvatar(
//             //   backgroundImage: AssetImage(
//             //     'assets/liquidgalaxylogo.png',
//             //   ),
//             //   radius: 100,
//             //   backgroundColor: Colors.transparent,
//             // ),
//             Container(
//               // margin: const EdgeInsets.all(15),
//               width: MediaQuery.of(context).size.width * 0.15,
//               height: MediaQuery.of(context).size.height * 0.15,
//               alignment: Alignment.center,
//               child: Image.asset(
//                 'assets/liquidgalaxylogo.png',
//               ),
//             ),
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.55,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignmentaceEvenly,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       // Handle reboot LG
//                       // Show warning pop-up
//                     },
//                     child: Text(
//                       'Reboot LG',
//                       style: TextStyle(
//                         color: textColor,
//                       ),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Handle move LG to home city
//                     },
//                     child: Text(
//                       'Move LG to Home City',
//                       style: TextStyle(
//                         color: textColor,
//                       ),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Handle make orbit upon arrival
//                     },
//                     child: Text(
//                       'Make Orbit Upon Arrival',
//                       style: TextStyle(
//                         color: textColor,
//                       ),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Handle print HTML bubble
//                     },
//                     child: Text(
//                       'Print HTML Bubble',
//                       style: TextStyle(
//                         color: textColor,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
