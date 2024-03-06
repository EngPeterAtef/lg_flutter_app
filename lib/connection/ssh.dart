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

  /// Property that defines the balloon slave screen number according to the [screenAmount] property. (Most right screen)
  int get balloonScreen {
    if (screenAmount == 1) {
      return 1;
    }

    // Gets the most right screen.
    return (screenAmount / 2).floor() + 1;
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
      screenAmount = int.parse(_numberOfRigs);
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

  /// Setups the Google Earth in slave screens to refresh every  second.
  Future<void> setRefresh() async {
    const search = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';
    const replace =
        '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>1<\\/refreshInterval>';
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

    // await reboot();
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

    // await reboot();
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

  Future<SSHSession?> buildOrbit(String content) async {
    String localPath = await _localPath;
    File localFile = File('$localPath/Orbit.kml');
    localFile.writeAsString(content);
    try {
      connectToLG();
      await _client?.run("echo '$content' > /var/www/html/Orbit.kml");
      return await _client!.execute(
          "echo '\nhttp://lg1:81/Orbit.kml' >> /var/www/html/kmls.txt");
      // return await _client!.execute('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (e) {
      debugPrint('Error in building orbit');
      return Future.error(e);
    }
  }

  // ///Orbit functionality:
  // Future<SSHSession?> startOrbit() async {
  //   try {
  //     return await _client!.execute('echo "playtour=Orbit" > /tmp/query.txt');
  //   } catch (e) {
  //     debugPrint('Could not connect to host LG');
  //     return Future.error(e);
  //   }
  // }

  // Future<SSHSession?> stopOrbit() async {
  //   try {
  //     return await _client!.execute('echo "exittour=true" > /tmp/query.txt');
  //   } catch (e) {
  //     debugPrint('Could not connect to host LG');
  //     return Future.error(e);
  //   }
  // }

  // Future<SSHSession?> cleanOrbit() async {
  //   try {
  //     return await _client!.execute('echo "" > /tmp/query.txt');
  //   } catch (e) {
  //     debugPrint('Could not connect to host LG');
  //     return Future.error(e);
  //   }
  // }

  Future<SSHSession?> openBalloon(
    String name,
    String track,
    String time,
    int height,
    String description,
  ) async {
    int rigs = balloonScreen;
    debugPrint('rigs: $rigs');

    String openBalloonKML = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document id="$rigs>
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
      <img src="https://myapp33bucket.s3.amazonaws.com/logoo.png" alt="picture" width="100" height="100" />
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
			<longitude>31.15261386906954</longitude>
			<latitude>30.07531669808784</latitude>
			<altitude>22.76128209356904</altitude>
			<heading>0</heading>
			<tilt>0</tilt>
			<gx:fovy>35</gx:fovy>
			<range>45471.87185313553</range>
			<altitudeMode>absolute</altitudeMode>
		</LookAt>
		<styleUrl>#purple_paddle</styleUrl>
		<gx:balloonVisibility>1</gx:balloonVisibility>
		<Point>
			<coordinates>31.20885559752747,30.01303892088913,25.75330199843935</coordinates>
		</Point>
	</Placemark>
</Document>
</kml>
''';

    try {
      return await _client!.execute(
          "echo '$openBalloonKML' > /var/www/html/kml/slave_$rigs.kml");
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<void> runKml(String kmlName) async {
    try {
      await _client?.execute(
          "echo 'http://lg1:81/$kmlName.kml' > /var/www/html/kmls.txt");

      debugPrint('kml uploaded');
    } catch (error) {
      debugPrint('Error in running kml');
    }
  }

  Future<void> cleanKML() async {
    try {
      if (_client == null) {
        debugPrint('SSH client is not initialized.');
        return;
      }
      int rigs = balloonScreen;
      debugPrint('rigs: $rigs');
      String openBalloonKML = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document id="$rigs">
  </Document>
</kml>
''';
      await _client!.execute(
          "echo '$openBalloonKML' > /var/www/html/kml/slave_$rigs.kml");

      // await _client?.execute('echo "" > /tmp/query.txt');
      // await _client?.execute("echo '' > /var/www/html/kmls.txt");
    } catch (error) {
      await connectToLG();
      await cleanKML();
      // showSnackBar(
      //     context: context, message: error.toString(), color: Colors.red);
    }
  }

  ///KML services:
  ///------------

  /// Sets the logos KML into the Liquid Galaxy rig. A KML [name] and [content] may be passed, but it's not required.
  Future<void> setLogos({
    String name = 'HAPIS-logos',
    String content = '<name>Logos</name>',
  }) async {
    String tag = '''
      <ScreenOverlay>
        <name>LogoSO</name>
        <Icon>
          <href>https://github.com/Mahy02/HAPIS-Refurbishment--Humanitarian-Aid-Panoramic-Interactive-System-/blob/main/hapis/assets/images/LOGO%20LIQUID%20GALAXY-sq1000-%20OKnoline.png?raw=true</href>
        </Icon>
        <color>ffffffff</color>
        <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
        <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
        <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
        <size x="382.5" y="297" xunits="pixels" yunits="pixels"/>
      </ScreenOverlay>
    ''';
    String kmlBody = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
    <name>$name</name>
    <open>1</open>
    <Folder>
      $content
      $tag
    </Folder>
  </Document>
</kml>
  ''';

    try {
      await sendKMLToSlave(logoScreen, kmlBody);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

//   /// Sends a KML [content] to the given slave [screen].
  Future<void> sendKMLToSlave(int screen, String content) async {
    try {
      await _client
          ?.execute("echo '$content' > /var/www/html/kml/slave_$screen.kml");
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  buildBallon() async {
    //https://github.com/Mahy02/LG_task2/blob/main/assets/images/cairo.png?raw=true
    String balloonContent = '''
    <div style="text-align:center;">
      <b><font size="+3"> 'Giza, Egypt' <font color="#5D5D5D"></font></font></b>
      </div>
      <br/><br/>
      <div style="text-align:center;">
      <img src="https://github.com/Mahy02/LG_task2/blob/main/assets/images/cairo.png?raw=true" style="display: block; margin: auto; width: 150px; height: 100px;"/><br/><br/>
     </div>
      <b>Peter Atef</b>
      <br/>
    ''';
    String kmlBody = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
    <name>City-balloon</name>
    <open>1</open>
    <Folder>
    <Style id="balloon-1">
      <BalloonStyle>
        <bgColor>000000</bgColor>
        <text><![CDATA[
         <html>
          <body style="font-family: montserrat, sans-serif; font-size: 18px; width: 400px; display: flex; justify-content: center; align-items: center;">
            <div style="background-color: #ffffff; padding: 10px; border-radius: 5px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);">
              <span style="color: black;">$balloonContent</span> <!-- Content of the balloon with red color -->
            </div>
          </body>
        </html>
        ]]></text>
      </BalloonStyle>
      <LabelStyle>
        <scale>0</scale>
      </LabelStyle>
      <IconStyle>
        <scale>0</scale>
      </IconStyle>
    </Style>
    <Placemark>
      <name>Giza, Egypt-Balloon</name>
      <styleUrl>#balloon-1</styleUrl>
      <gx:balloonVisibility>${balloonContent.isEmpty ? 0 : 1}</gx:balloonVisibility>
    </Placemark>
    </Folder>
  </Document>
</kml>
  ''';
    try {
      /// sending kml to slave where we send to `balloon screen` and send the `kml balloon ` body
      await sendKMLToSlave(
        balloonScreen,
        kmlBody,
      );
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  /// Generates a blank KML with the given [id].
  String _generateBlank(String id) {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document id="$id">
  </Document>
</kml>
    ''';
  }

  /// Clears all `KMLs` from the Google Earth. The [keepLogos] keeps the logos
  /// after clearing (default to `true`).
  Future<void> clearKml({bool keepLogos = true}) async {
    String query =
        'echo "exittour=true" > /tmp/query.txt && > /var/www/html/kmls.txt';
    for (var i = 2; i <= screenAmount; i++) {
      String blankKml = _generateBlank('slave_$i');
      query += " && echo '$blankKml' > /var/www/html/kml/slave_$i.kml";
    }

    if (keepLogos) {
      String logosTag = '''
      <BalloonStyle>
        <name>TempLogo</name>
        <Icon>
          <href>https://myapp33bucket.s3.amazonaws.com/logoo.png</href>
        </Icon>
        <color>ffffffff</color>
        <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
        <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
        <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
        <size x="382.5" y="297" xunits="pixels" yunits="pixels"/>
      </BalloonStyle>
    ''';
      String kmlBody = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
    <name>HAPIS-logos</name>
    <open>1</open>
    <Folder>
      <name>Logos</name>
      $logosTag
    </Folder>
  </Document>
</kml>
  ''';
      query += " && echo '$kmlBody' > /var/www/html/kml/slave_$logoScreen.kml";
    }
    try {
      await _client?.execute(query);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}
