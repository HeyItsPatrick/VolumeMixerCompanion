import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:volume_mixer/main.dart' as globals;

class AboutPanel extends StatefulWidget {
  @override
  _AboutPanelState createState() => _AboutPanelState();
}

class _AboutPanelState extends State<AboutPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Current IP Address:"),
        Text(globals.globalIPAddress.toString()),
        Text("Port Number:"),
        Text(globals.globalPort.toString()),
        Text(""),
        FutureBuilder(
          future: globals.futureInfo,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: snapshot.data,
              );
            } else if (snapshot.hasError) {
              return Text(
                "API error: ${snapshot.error}",
                textAlign: TextAlign.center,
              );
            }
            return Container();
          },
        ),
        SizedBox(
          height: 40.0,
        ),
        RaisedButton(
          child: Text("Enter new IP address"),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName("/"));
          },
        ),
      ],
    );
  }
}
