import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:volume_mixer/volume.dart';
import 'package:volume_mixer/main.dart' as globals;

class AboutPanel extends StatefulWidget {
  @override
  _AboutPanelState createState() => _AboutPanelState();
}

class _AboutPanelState extends State<AboutPanel> {
  Future<List<Text>> futureInfo;

  @override
  void initState() {
    super.initState();
    futureInfo = getSystemInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Current IP Address:"),
            Text(globals.globalIPAddress.toString()),
            Text(""),
            FutureBuilder(
              future: futureInfo,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // var widgetList = List<Widget>();
                  // for (var item in snapshot.data) {
                  //   widgetList.add(item);
                  // }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: snapshot.data,
                  );
                } else if (snapshot.hasError) {
                  return Text("API error: ${snapshot.error}");
                }
                return Container();
              },
            ),
            SizedBox(
              height: 40.0,
            ),
            FlatButton(
              child: Text("Enter new IP address"),
              colorBrightness: Brightness.light,
              color: Colors.grey,
              onPressed: (){ 
                Navigator.popUntil(context, ModalRoute.withName("/"));
              },
            ),
          ],
        ),
      ],
    );
  }
}
