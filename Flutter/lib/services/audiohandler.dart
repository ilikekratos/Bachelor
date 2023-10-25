import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:crash_app/myAPI.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';

class AudioHandler {
  Future<bool> recordAndSendAudio(String username, int Index) async {
    final _audioRecorder = FlutterSoundRecorder();
    _audioRecorder.setLogLevel(Level.nothing);
    final appDir = await getApplicationDocumentsDirectory();
    final audioPath = '${appDir.path}/audio$username$Index.wav';
    bool returned = false;
    if (await Permission.microphone
        .request()
        .isGranted && await Permission.storage
        .request()
        .isGranted) {
      await _audioRecorder.openAudioSession();
      await _audioRecorder.startRecorder(toFile: audioPath,
          codec: Codec.pcm16WAV,
          sampleRate: 22050,
          numChannels: 1,
          bitRate: 12800);
      await Future.delayed(const Duration(milliseconds: 2500));
      await _audioRecorder.stopRecorder();
      await _audioRecorder.closeAudioSession();
      //Send to python
      final url = Uri.parse(myAPI().pythonUrl);
      final request = http.MultipartRequest('POST', url);
      File audioFile = File(audioPath);
      final bytes = await audioFile.readAsBytes();
      request.fields['username'] = username;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'audio$username$Index.wav',
        contentType: MediaType('audio', 'wav'),
      ));
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final json = jsonDecode(responseBody);
        print(json['prediction']);
        if (json['prediction'] == 1) {
          print("True");
          returned = true;
        }
        print('File uploaded successfully');
        audioFile.delete();
      } else {
        print(
            'Failed to upload file. Status code: ${response.statusCode}$Index');
      }
    }
    return returned;
  }
}

