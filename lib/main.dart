import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound_player.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Boring Show',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EpisodesPage(),
    );
  }
}

class EpisodesPage extends StatelessWidget {
  final String url = 'https://itsallwidgets.com/podcast/feed';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: http.get(url),
        builder: (context, AsyncSnapshot<http.Response> snapshot) {
          if (snapshot.hasData) {
            final response = snapshot.data;
            if (response.statusCode == 200) {
              final rssString = response.body;
              var rssFeed = new RssFeed.parse(rssString);
              return EpisodeList(rssFeed: rssFeed);
            } else {
              Center(
                child: CircularProgressIndicator(),
              );
            }
          }
        },
      ),
    );
  }
}

class EpisodeList extends StatelessWidget {
  const EpisodeList({
    Key key,
    @required this.rssFeed,
  }) : super(key: key);

  final RssFeed rssFeed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: rssFeed.items
          .map((item) => ListTile(
                title: Text(item.title),
                subtitle: Text(
                  item.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlayerPage(item: item),
                    ),
                  );
                },
              ))
          .toList(),
    );
  }
}

class PlayerPage extends StatelessWidget {
  PlayerPage({this.item});

  final RssItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: SafeArea(
        child: Player(),
      ),
    );
  }
}

class Player extends StatelessWidget {
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
