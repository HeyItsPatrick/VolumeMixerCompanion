import 'package:flutter/material.dart';
import 'package:volume_mixer/volume.dart';
import 'package:volume_mixer/volume_widget.dart';

//TODO: Proper error handling and output. Right now api failures are uncaught
//TODO: "About" popup with system info, include ability to enter new IP
//TODO: QR code reader as input for ip address
//TODO: Only update one volume widget on updates instead of rebuilding the whole mixer
//TODO: When the Device volume moves, show the change in the app sliders
//TODO: When slider passes device max, set value to device max and not back to the former value

class VolumeMixer extends StatefulWidget {
  @override
  VolumeMixerState createState() => VolumeMixerState();

  static VolumeMixerState of(BuildContext context) {
    return context.findAncestorStateOfType<VolumeMixerState>();
  }
}

class VolumeMixerState extends State<VolumeMixer> {
  Future<List<Volume>> futureVolume;

  @override
  void initState() {
    super.initState();
    futureVolume = getVolumes();
  }

//total flag true forces a fresh api call and updates the snapshot, false just refreshes the states of the child widgets
  void rebuild({bool total = false}) {
    setState(() {
      if (total) futureVolume = getVolumes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          setState(() {
            futureVolume = getVolumes();
          });
        },
      ),
    );
  }
}
