import 'package:flutter/material.dart';
import 'package:volume_mixer/about_panel.dart';
import 'package:volume_mixer/main.dart' as globals;
import 'package:volume_mixer/volume.dart';
import 'package:volume_mixer/volume_widget.dart';

class VolumeMixer extends StatefulWidget {
  @override
  VolumeMixerState createState() => VolumeMixerState();

  static VolumeMixerState of(BuildContext context) {
    return context.findAncestorStateOfType<VolumeMixerState>();
  }
}

class VolumeMixerState extends State<VolumeMixer> {
  Future<List<Volume>> futureVolume;
  double deviceVolumeCap;

  @override
  void initState() {
    super.initState();
    futureVolume = getVolumes().catchError((error) => throw ErrorDescription(error));
    //Load system info once here, to prevent API calls every time the drawer is opened
    globals.futureInfo = getSystemInformation();
  }

  //total flag true forces a fresh api call and updates the snapshot, false just refreshes the states of the child widgets
  void rebuild() {
    var val = getVolumes().catchError((error) => throw ErrorDescription(error));
    setState(() {
      futureVolume = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Volume Mixer Companion"),
      ),
      drawer: Drawer(
        child: AboutPanel(),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: futureVolume,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    var widgetList = List<Widget>();
                    for (Volume item in snapshot.data) {
                      widgetList.add(VolumeWidget(item));
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widgetList,
                    );
                  } else if (snapshot.hasError) {
                    return Text("API error: ${snapshot.error}");
                  }
                }
                return Container();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Refresh volume data",
        child: Icon(Icons.refresh),
        onPressed: () {
          //Leave the function and SetState separate, as the setState callback will error out on the returned Future
          var val = getVolumes().catchError((error) => throw ErrorDescription(error));
          setState(() {
            futureVolume = val;
          });
        },
      ),
    );
  }
}
