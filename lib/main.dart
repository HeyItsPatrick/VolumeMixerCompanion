import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volume_mixer/volume_mixer.dart';

String globalIPAddress;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volume Mixer',
      theme: ThemeData(
brightness: Brightness.dark,
        primaryColorBrightness: Brightness.dark,
        accentColorBrightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        accentColor: Colors.grey,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("IP Address"),
              TextFormField(
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp("[0-9.]"))
                ],
                validator: (value) {
                  var regEx =
                      RegExp(r'^\d{1,3}[.]\d{1,3}[.]\d{1,3}[.]\d{1,3}$');
                  if (value.isEmpty)
                    return "IP Address is required";
                  else if (!regEx.hasMatch(value))
                    return "Incorrectly formatted IP Address";
                  else {
                    globalIPAddress = value;
                    return null;
                  }
                },
              ),
              RaisedButton(
                onPressed: () {
                  final state = _formKey.currentState;
                  if (state.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VolumeMixer(),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
