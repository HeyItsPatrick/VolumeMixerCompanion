import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:volume_mixer/main.dart' as globals;

class Volume {
  int currentVolume;
  int processId;
  String programName;
  Image icon;

  Volume({this.currentVolume, this.processId, this.programName, this.icon});

  factory Volume.fromJson(Map<String, dynamic> json) {
    return Volume(
      currentVolume: json["currentVolume"],
      processId: json["processID"],
      programName: json["programName"],
      icon: Image.memory(Base64Codec().decode(json["programIcon"] ?? "")),
    );
  }
}

Future<List<Volume>> getVolumes() async {
  String url = globals.baseURL + "all";
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var volumeList = List<Volume>();
    for (var item in json.decode(response.body)) {
      volumeList.add(Volume.fromJson(item));
    }
    return volumeList;
  } else {
    throw Exception("API: GET volume data failed.");
  }
}

Future<Volume> getVolumeByProcessID(int processID) async {
  String url = globals.baseURL + processID.toString();
  var response = await http.get(url);
  if (response.statusCode == 200) {
    return Volume.fromJson(json.decode(response.body));
  } else {
    throw Exception("API: GET volume by ID failed.");
  }
}

Future<bool> updateVolume(int processId, int newVolume) async {
  String url =
      globals.baseURL + processId.toString() + "/" + newVolume.toString();
  var response = await http.put(url);
  return response.body == "true";
}

Future<List<Text>> getSystemInformation() async {
  String url = globals.baseURL;
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var infoList = List<Text>();
    for (var item in json.decode(response.body)) {
      infoList.add(Text(item.toString()));
    }
    return infoList;
  } else {
    throw Exception("API: GET system information failed.");
  }
}
