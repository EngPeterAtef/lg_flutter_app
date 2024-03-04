// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:lg_app/models/look_at_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class SSH {
  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  SSHClient? _client;

  /// Property that defines the master rig url.
  final String _url = 'http://lg1:81';

  /// Property that defines number of screens. Defaults to `5`.
  int screenAmount = 5;

  /// Lg order:  if 5 => 5 4 1 2 3   if 3 => 3 1 2

  /// Property that defines the logo slave screen number according to the [screenAmount] property. (Most left screen)
  int get logoScreen {
    int sA = int.parse(_numberOfRigs);
    if (sA == 1) {
      return 1;
    }

    // Gets the most left screen.
    return (sA / 2).floor() + 2;
  }

  // Initialize connection details from shared preferences
  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  // Connect to the Liquid Galaxy system
  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    try {
      //Connect to Liquid Galaxy system, using examples from https://pub.dev/packages/dartssh2#:~:text=freeBlocks%7D%27)%3B-,%F0%9F%AA%9C%20Example%20%23,-SSH%20client%3A
      _client = SSHClient(
        await SSHSocket.connect(_host, int.parse(_port)),
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );
      return true;
    } on SocketException catch (e) {
      debugPrint('Failed to connect: $e');
      return false;
    }
  }

  Future<SSHSession?> execute(String command) async {
    try {
      if (_client == null) {
        debugPrint('SSH client is not initialized.');
        return null;
      }
      // Execute a demo command: echo "search=Lleida" >/tmp/query.txt
      return _client?.execute(command);
    } catch (e) {
      debugPrint('An error occurred while executing the command: $e');
      return null;
    }
  }

  ///Liquid Galaxy Services:
  ///-----------------------

  /// Relaunching the Liquid Galaxy System:
  /// We used to type: --lg-relaunch  in terminal
  Future<void> relaunch() async {
    screenAmount = int.parse(_numberOfRigs);

    for (var i = screenAmount; i >= 1; i--) {
      try {
        final relaunchCommand = """RELAUNCH_CMD="\\
if [ -f /etc/init/lxdm.conf ]; then
  export SERVICE=lxdm
elif [ -f /etc/init/lightdm.conf ]; then
  export SERVICE=lightdm
else
  exit 1
fi
if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
  echo $_passwordOrKey | sudo -S service \\\${SERVICE} start
else
  echo $_passwordOrKey | sudo -S service \\\${SERVICE} restart
fi
" && sshpass -p $_passwordOrKey ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";

        await _client?.execute(
            "'/home/$_username/bin/lg-relaunch' > /home/$_username/log.txt");

        await _client?.execute(relaunchCommand);
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
  }

  /// Reboots the Liquid Galaxy system.
  /// We used to write sudo reboot  in the terminal, but we need a way to add the password and the LG number too here
  Future<void> reboot() async {
    screenAmount = int.parse(_numberOfRigs);

    for (var i = screenAmount; i > 1; i--) {
      // print('reboot');
      // print(i);
      try {
        await _client?.execute(
            'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S reboot"');
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
    try {
      await _client?.execute(
          'sshpass -p $_passwordOrKey ssh -t lg1 "echo $_passwordOrKey | sudo -S reboot"');
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  /// Shuts down the Liquid Galaxy system.
  Future<void> shutdown() async {
    screenAmount = int.parse(_numberOfRigs);

    for (var i = screenAmount; i >= 1; i--) {
      try {
        await _client?.execute(
            'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S poweroff"');
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
  }

  /// Search about a place in the Google Earth.
  Future<SSHSession?> searchPlace(String placeName) async {
    try {
      connectToLG();
      final execResult =
          await _client?.execute('echo "search=$placeName" >/tmp/query.txt');
      return execResult;
    } catch (e) {
      debugPrint('An error occurred while executing the command: $e');
      return null;
    }
  }

  /// Setups the Google Earth in slave screens to refresh every 2 seconds.
  Future<void> setRefresh() async {
    const search = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';
    const replace =
        '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
    final command =
        'echo $_passwordOrKey | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

    final clear =
        'echo $_passwordOrKey | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml';

    for (var i = 2; i <= screenAmount; i++) {
      final clearCmd = clear.replaceAll('{{slave}}', i.toString());
      final cmd = command.replaceAll('{{slave}}', i.toString());
      String query = 'sshpass -p $_passwordOrKey ssh -t lg$i \'{{cmd}}\'';

      try {
        await _client?.execute(query.replaceAll('{{cmd}}', clearCmd));
        await _client?.execute(query.replaceAll('{{cmd}}', cmd));
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }

    await reboot();
  }

  /// Setups the Google Earth in slave screens to stop refreshing.
  Future<void> resetRefresh() async {
    const search =
        '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
    const replace = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';

    final clear =
        'echo $_passwordOrKey | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

    for (var i = 2; i <= screenAmount; i++) {
      final cmd = clear.replaceAll('{{slave}}', i.toString());
      String query = 'sshpass -p $_passwordOrKey ssh -t lg$i \'$cmd\'';

      try {
        await _client?.execute(query);
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }

    await reboot();
  }

  /// Puts the given [content] into the `/tmp/query.txt` file.
  Future<void> query(String content) async {
    await _client?.execute('echo "$content" > /tmp/query.txt');
  }

  ///Fly to functionality:
  /// Command to fly to a certain location: 'echo "flytoview=${flyto.generateLinearString()}" > /tmp/query.txt'
  /// Uses the [query] method to fly to some place in Google Earth according to the given [lookAt].
  /// See [LookAtModel].
  Future<void> flyTo(LookAtModel lookAt) async {
    try {
      await query('flytoview=${lookAt.linearTag}');
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  ///Orbit functionality:
  /// Uses the [query] method to play some tour in Google Earth according to  the given [tourName].
  /// Command: 'echo "playtour=Orbit" > /tmp/query.txt'
  Future<void> startTour(String tourName) async {
    try {
      debugPrint('here play tour');
      await query('playtour=$tourName');
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  /// Uses the [query] method to stop all tours in Google Earth.
  Future<void> stopTour() async {
    try {
      await query('exittour=true');
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  buildOrbit(String content) async {
    String localPath = await _localPath;
    File localFile = File('$localPath/Orbit.kml');
    localFile.writeAsString(content);
    try {
      connectToLG();
      await _client?.run("echo '$content' > /var/www/html/Orbit.kml");
      await _client!.execute(
          "echo '\nhttp://lg1:81/Orbit.kml' >> /var/www/html/kmls.txt");
      return await _client!.execute('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (e) {
      debugPrint('Error in building orbit');
      return Future.error(e);
    }
  }

  startOrbit() async {
    try {
      return await _client!.execute('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (e) {
      debugPrint('Could not connect to host LG');
      return Future.error(e);
    }
  }

  stopOrbit() async {
    try {
      return await _client!.execute('echo "exittour=true" > /tmp/query.txt');
    } catch (e) {
      debugPrint('Could not connect to host LG');
      return Future.error(e);
    }
  }

  cleanOrbit() async {
    try {
      return await _client!.execute('echo "" > /tmp/query.txt');
    } catch (e) {
      debugPrint('Could not connect to host LG');
      return Future.error(e);
    }
  }

  openBalloon(
    String name,
    String track,
    String time,
    int height,
    String description,
  ) async {
    int rigs = (int.parse(_numberOfRigs) / 2).floor() + 1;
    String openBalloonKML = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<name>$name.kml</name>
	<Style id="purple_paddle">
		<BalloonStyle>
			<text>\$[description]</text>
      <bgColor>4169E11e</bgColor>
		</BalloonStyle>
	</Style>
	<Placemark id="0A7ACC68BF23CB81B354">
		<name>$track</name>
		<Snippet maxLines="0"></Snippet>
		<description><![CDATA[<!-- BalloonStyle background color:
ffffffff
 -->
<table width="400" border="0" cellspacing="0" cellpadding="5">
  <tr>
    <td colspan="2" align="center">
      <img src="https://myapp33bucket.s3.amazonaws.com/logoo.png" alt="picture" width="150" height="150" />
    </td>
  </tr>
  <tr>
    <td colspan="2" align="center">
      <h1><font color='#00CC99'>$track</font></h1>
      <h1><font color='#00CC99'>$time</font></h1>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <p><font color="#3399CC">$description</font></p>
    </td>
  </tr>
</table>]]></description>
		<LookAt>
			<longitude>72.81555865828552</longitude>
			<latitude>18.956721869849535</latitude>
			<altitude>0</altitude>
			<heading>0</heading>
			<tilt>0</tilt>
			<range>24000</range>
		</LookAt>
		<styleUrl>#purple_paddle</styleUrl>
		<gx:balloonVisibility>1</gx:balloonVisibility>
		<Point>
			<coordinates>72.81555865828552,18.956721869849535,0</coordinates>
		</Point>
	</Placemark>
</Document>
</kml>
''';
    try {
      connectToLG();
      return await _client!.execute(
          "echo '$openBalloonKML' > /var/www/html/kml/slave_$rigs.kml");
    } catch (e) {
      return Future.error(e);
    }
  }

  ///KML services:
  ///------------

  ///Visualizing the uploaded KML on LG command: echo "http://lg1:81/$projectname.kml" > /var/www/html/kmls.txt'
  ///Sending tour to the Google Earth using the KML file and the tourname ex: Orbit
  /// Sends and starts a `tour` into the Google Earth.
  // Future<void> sendTour(String tourKml, String tourName) async {
  //   final fileName = '$tourName.kml';
  //   try {
  //     final kmlFile = await _fileService.createFile(fileName, tourKml);

  //     await _client.uploadKml(kmlFile, fileName);
  //     debugPrint('kml uploaded');

  //     await _client
  //         .execute('echo "\n$_url/$fileName" >> /var/www/html/kmls.txt');
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print(e.toString());
  //   }
  // }

  // /// Sets the logos KML into the Liquid Galaxy rig. A KML [name] and [content] may be passed, but it's not required.
  // Future<void> setLogos({
  //   String name = 'HAPIS-logos',
  //   String content = '<name>Logos</name>',
  // }) async {
  //   final screenOverlay = ScreenOverlayModel.logos();

  //   final kml = KMLModel(
  //     name: name,
  //     content: content,
  //     screenOverlay: screenOverlay.tag,
  //   );
  //   try {
  //     await sendKMLToSlave(logoScreen, kml.body);
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print(e);
  //   }
  // }

  // /// Sends a KML [content] to the given slave [screen].
  // Future<void> sendKMLToSlave(int screen, String content) async {
  //   try {
  //     await _client
  //         .execute("echo '$content' > /var/www/html/kml/slave_$screen.kml");
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print(e);
  //   }
  // }

  // /// Sends a the given [kml] to the Liquid Galaxy system.
  // ///
  // /// It also accepts a [List] of images represents by [Map]s. The [images] must
  // /// have the following pattern:
  // /// ```
  // /// [
  // ///   {
  // ///     'name': 'img-1.png',
  // ///     'path': 'path/to/img-1'
  // ///   },
  // ///   {
  // ///     'name': 'img-2.png',
  // ///     'path': 'path/to/img-2'
  // ///   }
  // /// ]
  // /// ```
  // Future<void> sendKml(KMLModel kml,
  //     {List<Map<String, String>> images = const []}) async {
  //   final fileName = '${kml.name}.kml';

  //   for (var img in images) {
  //     final image = await _fileService.createImage(img['name']!, img['path']!);
  //     String imageName = img['name']!;
  //     try {
  //       await _client.uploadKml(image, imageName);
  //     } catch (e) {
  //       // ignore: avoid_print
  //       print(e);
  //     }
  //   }
  //   try {
  //     final kmlFile = await _fileService.createFile(fileName, kml.body);
  //     await _client.uploadKml(kmlFile, fileName);
  //     await _client.execute('echo "$_url/$fileName" > /var/www/html/kmls.txt');
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print(e);
  //   }
  // }

  // Future<void> sendKmlPins(String pinsKml, String placemarkName) async {
  //   final fileName = '$placemarkName.kml';
  //   try {
  //     final kmlFile = await _fileService.createFile(fileName, pinsKml);

  //     await _client?.uploadKml(kmlFile, fileName);

  //     await _client
  //         ?.execute('echo "\n$_url/$fileName" >> /var/www/html/kmls.txt');
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print(e);
  //   }
  // }

  // /// Clears all `KMLs` from the Google Earth. The [keepLogos] keeps the logos
  // /// after clearing (default to `true`).
  // Future<void> clearKml({bool keepLogos = true}) async {
  //   String query =
  //       'echo "exittour=true" > /tmp/query.txt && > /var/www/html/kmls.txt';
  //   for (var i = 2; i <= screenAmount; i++) {
  //     String blankKml = KMLModel.generateBlank('slave_$i');
  //     query += " && echo '$blankKml' > /var/www/html/kml/slave_$i.kml";
  //   }

  //   if (keepLogos) {
  //     final kml = KMLModel(
  //       name: 'HAPIS-logos',
  //       content: '<name>Logos</name>',
  //       screenOverlay: ScreenOverlayModel.logos().tag,
  //     );

  //     query +=
  //         " && echo '${kml.body}' > /var/www/html/kml/slave_$logoScreen.kml";
  //   }
  //   try {
  //     await _client?.execute(query);
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print(e);
  //   }
  // }
}
