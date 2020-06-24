import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Boring Show',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BoringPage(),
    );
  }
}

class BoringPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DashCastApp(),
      ),
    );
  }
}

class DashCastApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 9,
          child: Placeholder(),
        ),
        Flexible(
          flex: 2,
          child: AudioControls(),
        ),
      ],
    );
  }
}

class AudioControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlaybackButtons(),
      ],
    );
  }
}

class PlaybackButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PlaybackButton(),
      ],
    );
  }
}

class PlaybackButton extends StatefulWidget {
  @override
  _PlaybackButtonState createState() => _PlaybackButtonState();
}

class _PlaybackButtonState extends State<PlaybackButton> {
  bool _isPlaying = false;
  FlutterSoundPlayer _sound;
  double _playPosition;
  Stream<PlayStatus> _playerSubscription;

  void _stop() async {
    print('Stopping');
    await _sound.stopPlayer();
    setState(() => _isPlaying = false);
  }

  void _play() async {
    final url =
        'https://s3-us-west-2.amazonaws.com/anchor-audio-bank/production/2020-2-8/55332291-44100-2-920107b8952c8.mp3';
    await _sound.startPlayer(url);

    _playerSubscription = _sound.onPlayerStateChanged
      ..listen((e) {
        if (e != null) {
          _playPosition = e.currentPosition;
          if (_playPosition != 0) {
            print(e.currentPosition);
          }
          setState(() => _playPosition = e.currentPosition / e.duration);
        }
      });
    setState(() => _isPlaying = true);
  }

  void _fastForward() {}

  void _rewind() {}

  @override
  void initState() {
    super.initState();
    _sound = new FlutterSoundPlayer();
    _playPosition = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Slider(
          value: _playPosition,
          onChanged: (newValue) {
            _playPosition = newValue;
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: Icon(Icons.fast_rewind), onPressed: null),
            IconButton(
              icon: _isPlaying ? Icon(Icons.stop) : Icon(Icons.play_arrow),
              onPressed: () {
                if (_isPlaying) {
                  _stop();
                } else {
                  _play();
                }
              },
            ),
            IconButton(icon: Icon(Icons.fast_forward), onPressed: null),
          ],
        ),
      ],
    );
  }
}
