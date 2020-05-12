import 'package:flutter/material.dart';
import 'package:volume_mixer/volume.dart';
import 'package:volume_mixer/volume_mixer.dart' as parent;

class VolumeWidget extends StatefulWidget {
  final Volume _volume;
  VolumeWidget(this._volume);

  @override
  _VolumeWidgetState createState() => _VolumeWidgetState();
}

class _VolumeWidgetState extends State<VolumeWidget> {
  double _sliderValue;

  void adjustVolume(double value) async {
    if (await updateVolume(widget._volume.processId, value.toInt())) {
      setState(() {
        widget._volume.currentVolume = value.toInt();
        _sliderValue = value;
      });
    } else {
      setState(() => _sliderValue = widget._volume.currentVolume.toDouble());
    }
    parent.VolumeMixer.of(context).rebuild();
  }

  @override
  void initState() {
    super.initState();
    _sliderValue = widget._volume.currentVolume.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 100,
          child: Column(children: [
            widget._volume.icon,
            Text(
              "${widget._volume.programName}",
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ]),
        ),
        IconButton(
          icon: Icon(
            Icons.volume_down,
          ),
          onPressed: () => adjustVolume(_sliderValue - 1),
        ),
        Column(
          children: <Widget>[
            Slider(
              value: _sliderValue,
              onChanged: (double value) => setState(() => _sliderValue = value),
              onChangeEnd: (double value) => adjustVolume(value),
              divisions: 100,
              min: 0,
              max: 100.0,
            ),
            Text("${widget._volume.currentVolume}"),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.volume_up,
          ),
          onPressed: () => adjustVolume(_sliderValue + 1),
        ),
      ],
    );
  }
}
