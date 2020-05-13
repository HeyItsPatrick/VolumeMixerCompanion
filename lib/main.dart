import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volume_mixer/volume_mixer.dart';

String globalIPAddress;
String baseURL;
Future<List<Text>> futureInfo;

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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter Computer IP Address",
                    hintText: "123.123.123.123",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp("[0-9.\n]"))
                  ],
textInputAction: TextInputAction.done,
onFieldSubmitted: (value){
_formKey.currentState.validate();
},
                  validator: (value) {
                    var regEx =
                        RegExp(r'^\d{1,3}[.]\d{1,3}[.]\d{1,3}[.]\d{1,3}$');
                    if (value.isEmpty)
                      return "IP Address is required";
                    else if (!regEx.hasMatch(value))
                      return "Incorrectly formatted IP Address";
                    else {
                      globalIPAddress = value;
                      baseURL = "http://" + value + ":8080/volume/";
                      return null;
                    }
                  },
                ),
                RaisedButton(
                  child: Text("Connect"),
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
      ),
    );
  }
}
