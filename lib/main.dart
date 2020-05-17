import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volume_mixer/volume_mixer.dart';

String globalIPAddress;
String baseURL;
String globalPort;
Future<List<Text>> futureInfo;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final Color background = Color.fromARGB(255, 18, 18, 18); //black #121212
  final Color surface = Color.fromARGB(255, 33, 33, 33); //light black #212121
  final Color primary = Color.fromARGB(255, 31, 41, 51); //greyblue #1F2933
  final Color primaryVariant = Color.fromARGB(255, 19, 25, 31); //#13191F
  final Color secondary = Color.fromARGB(255, 241, 202, 161); //tan #F1CAA1
  final Color secondaryVariant = Color.fromARGB(255, 145, 121, 97); //#917961
  final Color text = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volume Mixer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        //sets everything to those from ThemeData.dark()
        //Simple baseline to keep until I make full TextThemes
        //Comments do not reflect *everything* the setting changes, just what is apparent in my project

        //will most likely need to move over to just a ColorScheme eventually
        //flutter.dev/go/material-theme-system-updates

        //FAB background color
        accentColor: secondary,
        accentColorBrightness: Brightness.light,
        //Raised Button
        buttonTheme: ButtonThemeData(
          buttonColor: secondary,
          textTheme: ButtonTextTheme.primary,
        ),
        //Drawer background
        canvasColor: background,
        cursorColor: secondary,
        dialogBackgroundColor: surface,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: secondary,
          foregroundColor: background,
        ),
        //Uncontained IconButton,Icon
        iconTheme: IconThemeData(color: secondary),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          fillColor: surface,
          filled: true,
        ),
        //AppBar
        primaryColor: primary,
        //AppBar text color
        primaryColorBrightness: Brightness.dark,
        //AppBar hamburger menu icon
        primaryIconTheme: IconThemeData(color: text),
        scaffoldBackgroundColor: background,
        sliderTheme: SliderThemeData(
          activeTrackColor: secondary,
          inactiveTrackColor: secondaryVariant,
          overlayColor: secondaryVariant.withOpacity(.25),
          thumbColor: secondary,
        ),
        //Selection background color
        textSelectionColor: secondary,
        //Popups that define edges of selection
        textSelectionHandleColor: secondary,
        textTheme: TextTheme(
          //Uncontained Text widget
          bodyText2: TextStyle(color: text),
          //Dialog title
          // headline6: TextStyle(color: text),
          //Dialog body, textfield input body
          // subtitle1: TextStyle(color: text),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

//Stateless because as soon as input is received, we navigate away from this page
class Home extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    icon: IconButton(
                      icon: Icon(Icons.camera_alt),
                      tooltip: "Capture QR Code",
                      onPressed: () => scanQRCode(context),
                    ),
                    labelText: "Enter Computer IP Address",
                    hintText: "123.123.123.123",
                    //So error text doesn't change widget position
                    helperText: " ",
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp("[0-9.\n]")),
                  ],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (value) => _formKey.currentState.validate(),
                  validator: (value) => validateIPAddress(value),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 65.0,
                  ),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Enter Port Number",
                          hintText: "5000",
                          helperText: " ",
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          WhitelistingTextInputFormatter(RegExp("[0-9\n]")),
                        ],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (value) => _formKey.currentState.validate(),
                        validator: (value) => validatePort(value),
                      ),
                      RaisedButton(
                        child: Text("Connect"),
                        onPressed: () {
                          final state = _formKey.currentState;
                          if (state.validate()) {
                            baseURL = "http://" + globalIPAddress + ":" + globalPort + "/volume/";
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VolumeMixer(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future scanQRCode(BuildContext context) async {
    try {
      var options = ScanOptions(
        strings: {"cancel": "Cancel", "flash_on": "Flash On", "flash_off": "Flash Off"},
        restrictFormat: [BarcodeFormat.qr], //Only recognize QR codes and no other types of barcode
        autoEnableFlash: false,
        android: AndroidOptions(useAutoFocus: true),
      );
      ScanResult result = await BarcodeScanner.scan(options: options);
      if (result.type == ResultType.Barcode) {
        List<String> splitInput = result.rawContent.split(":");
        if (splitInput.length != 2) showErrorDialog("Improperly formatted QR code data.\nShould be {IP Address}:{Port Number}", context);
        String validMessage = (validateIPAddress(splitInput[0]) ?? "") + "\n" + (validatePort(splitInput[1]) ?? "");
        if (validMessage.trim().isEmpty) {
          baseURL = "http://" + globalIPAddress + ":" + globalPort + "/volume/";
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VolumeMixer(),
            ),
          );
        } else {
          showErrorDialog(validMessage, context);
        }
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        showErrorDialog("App needs Camera permissions for this functionality.", context);
      } else {
        showErrorDialog("Unknown error: $e", context);
      }
    }
  }

  String validateIPAddress(String value) {
    var regEx = RegExp(r'^\d{1,3}[.]\d{1,3}[.]\d{1,3}[.]\d{1,3}$');
    if (value.isEmpty)
      return "IP Address is required";
    else if (!regEx.hasMatch(value))
      return "Incorrectly formatted IP Address";
    else {
      globalIPAddress = value;
      return null;
    }
  }

  String validatePort(String value) {
    var regEx = RegExp(r'^\d+$');
    if (value.isEmpty)
      return "Port number is required";
    else if (!regEx.hasMatch(value))
      return "Incorrectly formatted Port number";
    else {
      globalPort = value;
      return null;
    }
  }

  void showErrorDialog(String errorMessage, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(errorMessage),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "OK",
                // style: TextStyle(
                //   color: Theme.of(context).textTheme.bodyText2.color,
                // ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
