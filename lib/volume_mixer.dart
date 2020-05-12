import 'package:flutter/material.dart';
import 'package:volume_mixer/about_panel.dart';
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
      appBar: AppBar(title: Text("Title"),),
      drawer: Drawer(child: AboutPanel(),),
      body:  SafeArea(
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
