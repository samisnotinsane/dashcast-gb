import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound_player.dart';
import 'package:provider/provider.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;

final String url = 'https://itsallwidgets.com/podcast/feed';

class Podcast with ChangeNotifier {
  RssFeed _feed;
  RssItem _selectedItem;

  RssFeed get feed => _feed;
  void parse(String url) async {
    final res = await http.get(url);
    final xmlStr = res.body;
    _feed = RssFeed.parse(xmlStr);
    notifyListeners();
  }

  set feed(RssFeed value) {
    _feed = value;
    notifyListeners();
  }

  RssItem get selectedItem => _selectedItem;
  set selectedItem(RssItem value) {
    _selectedItem = value;
    notifyListeners();
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Podcast()..parse(url),
      child: MaterialApp(
        title: 'The Boring Show',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: EpisodesPage(),
      ),
    );
  }
}

class EpisodesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<Podcast>(
        builder: (context, podcast, _) {
          return podcast.feed != null
              ? EpisodeList(
                  rssFeed: podcast.feed,
                )
              : Center(child: CircularProgressIndicator());
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
                  Provider.of<Podcast>(context, listen: false).selectedItem =
                      item;
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PlayerPage()),
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
        title: Text(Provider.of<Podcast>(context).selectedItem.title),
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
    final podcast = Provider.of<Podcast>(context);
    return Column(
      children: [
        Flexible(
          flex: 5,
          child: Image.network(
            podcast.feed.image.url,
            fit: BoxFit.cover,
          ),
        ),
        Flexible(
          flex: 4,
          child: SingleChildScrollView(
            child: Text(podcast._selectedItem.description),
          ),
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

  void _play(String url) async {
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
    final item = Provider.of<Podcast>(context).selectedItem;

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
                  _play(item.guid);
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
