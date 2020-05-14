import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
      //This will throw "could not instantiate image codec" exception forever because Dart doesn't know the file extention for this image type
      icon: Image.memory(base64Decode(json["programIcon"])),
    );
  }
}

Future<List<Volume>> getVolumes() async {
  var response =
      await _executeAction(() => http.get(globals.baseURL + "all"), "GET All");

  var volumeList = List<Volume>();
  for (var item in json.decode(response.body)) {
    volumeList.add(Volume.fromJson(item));
  }
  return volumeList;
}

Future<Volume> getVolumeByProcessID(int processID) async {
  var response = await _executeAction(
      () => http.get(globals.baseURL + processID.toString()), "GET Volume");
  return Volume.fromJson(json.decode(response.body));
}

Future<bool> updateVolume(int processId, int newVolume) async {
  var response = await _executeAction(
      () => http.put(
          globals.baseURL + processId.toString() + "/" + newVolume.toString()),
      "PUT New Volume");
  return response.body == "true";
}

Future<List<Text>> getSystemInformation() async {
  var response =
      await _executeAction(() => http.get(globals.baseURL), "GET System");

  var infoList = List<Text>();
  for (var item in json.decode(response.body)) {
    infoList.add(Text(item.toString().trim(),textAlign: TextAlign.center,));
  }
  return infoList;
}

Future<http.Response> _executeAction(
    Function apiCall, String errorPrefix) async {
  try {
    var response = await apiCall();
    if (response.statusCode == 200) {
      return response;
    } else {
      return Future.error(
          errorPrefix + " response status: " + response.statusCode.toString());
    }
  } catch (e) {
    return Future.error(
        errorPrefix + " failed: " + (e as SocketException).osError.message);
  }
}
