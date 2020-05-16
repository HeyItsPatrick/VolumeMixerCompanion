import 'package:flutter/material.dart';
import 'package:volume_mixer/volume.dart';
import 'package:volume_mixer/volume_mixer.dart' as parent;

const Color disabledColor = Colors.red;

class VolumeWidget extends StatefulWidget {
  final Volume _volume;
  VolumeWidget(this._volume);

  @override
  _VolumeWidgetState createState() => _VolumeWidgetState();
}

class _VolumeWidgetState extends State<VolumeWidget> {
  double _sliderValue;
  Color thumbColor;

  Future<void> adjustVolume(double value, context) async {
    //Use the color change to dynamically "disable" any volume changes until there is a response from the API
    if (thumbColor == disabledColor) return;
    //Slide up to the device limit without jerking back to starting position if you go over
    if (value > parent.VolumeMixer.of(context).deviceVolumeCap && widget._volume.processId >= 0)
      value = parent.VolumeMixer.of(context).deviceVolumeCap;

    //"Disable" the slider while waiting for the API call to finish
    //There is no indication of activity in the app, so specifically in the case of poor/slow connection
    //The user shouldn't be allowed to spam several more calls while waiting for action
    setState(() {
      thumbColor = disabledColor;
    });
    if (await updateVolume(widget._volume.processId, value.toInt())) {
      setState(() {
        widget._volume.currentVolume = value.toInt();
        _sliderValue = value;
      });
      if (widget._volume.processId < 0) {
        //if successful Device update, refresh the whole Mixer to update max caps
        parent.VolumeMixer.of(context).rebuild();
      }
    } else {
      //If API call fails, revert to previous position
      setState(() {
        _sliderValue = widget._volume.currentVolume.toDouble();
      });
    }
    //"Enable" the slider
    setState(() {
      thumbColor = Theme.of(context).sliderTheme.thumbColor;
    });
  }

  @override
  void initState() {
    super.initState();
    _sliderValue = widget._volume.currentVolume.toDouble();
    if (widget._volume.processId < 0) parent.VolumeMixer.of(context).deviceVolumeCap = widget._volume.currentVolume.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 100,
          child: Column(
            children: [
              widget._volume.icon,
              Text(
                "${widget._volume.programName}",
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.volume_down,
          ),
          onPressed: () async => await adjustVolume(_sliderValue - 1, context),
        ),
        Column(
          children: <Widget>[
            SliderTheme(
              data: SliderTheme.of(context).copyWith(thumbColor: thumbColor),
              child: Slider(
                value: _sliderValue,
                onChanged: (double value) {
                  if (thumbColor != disabledColor)
                    setState(() {
                      _sliderValue = value;
                    });
                },
                onChangeEnd: (double value) async => await adjustVolume(value, context),
                divisions: 100,
                min: 0,
                max: 100.0,
              ),
            ),
            Text("${widget._volume.currentVolume}"),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.volume_up,
          ),
          onPressed: () async => await adjustVolume(_sliderValue + 1, context),
        ),
      ],
    );
  }
}
