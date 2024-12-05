import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerExample extends StatefulWidget {
  @override
  _AudioPlayerExampleState createState() => _AudioPlayerExampleState();
}

class _AudioPlayerExampleState extends State<AudioPlayerExample> {
  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isContainerVisibleNotifier = ValueNotifier(false);

  bool isVolumeVisible = false;
  Duration totalDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  double volume = 0.5;

  List<Map<String, String>> tracks = [
    {
      'name': 'Song 1',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
    },
    {
      'name': 'Song 2',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'
    },
    {
      'name': 'Song 3',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'
    },
  ];
  int currentTrackIndex = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadTrack();

    _player.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    _player.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position;
      });
    });

    _player.onPlayerComplete.listen((event) async {
      await _playNextTrack();
    });
  }

  Future<bool> _isTrackAvailable(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Ошибка проверки трека: $e');
      return false;
    }
  }

  Future<void> _savePosition(int trackIndex, Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('track_${trackIndex}_position', position.inSeconds);
  }

  Future<void> _restorePosition(int trackIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosition = prefs.getInt('track_${trackIndex}_position');
    if (savedPosition != null) {
      final restoredPosition = Duration(seconds: savedPosition);
      await _player.seek(restoredPosition);
      setState(() {
        currentPosition = restoredPosition;
      });
    }
  }

  Future<void> _loadTrack() async {
    try {
      final trackUrl = tracks[currentTrackIndex]['url']!;
      if (await _isTrackAvailable(trackUrl)) {
        await _player.setSourceUrl(trackUrl);
        await _restorePosition(currentTrackIndex);
        await _player.setVolume(volume);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Не удалось загрузить трек: ${tracks[currentTrackIndex]['name']}',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Ошибка загрузки трека: $e');
    }
  }

  Future<void> _playNextTrack() async {
    await _savePosition(currentTrackIndex, currentPosition);
    if (currentTrackIndex < tracks.length - 1) {
      currentTrackIndex++;
    } else {
      currentTrackIndex = 0;
    }
    await _loadTrack();
    if (isPlayingNotifier.value) {
      await _player.resume();
    }
  }

  Future<void> _playPreviousTrack() async {
    await _savePosition(currentTrackIndex, currentPosition);
    if (currentTrackIndex > 0) {
      currentTrackIndex--;
    } else {
      currentTrackIndex = tracks.length - 1;
    }
    await _loadTrack();
    if (isPlayingNotifier.value) {
      await _player.resume();
    }
  }

  Future<void> _togglePlayPause() async {
    if (isPlayingNotifier.value) {
      await _player.pause();
    } else {
      isContainerVisibleNotifier.value = true;
      await _player.resume();
    }
    isPlayingNotifier.value = !isPlayingNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: isPlayingNotifier,
            builder: (context, isPlaying, child) {
              return IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 40,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: ValueListenableBuilder<bool>(
              valueListenable: isContainerVisibleNotifier,
              builder: (context, isContainerVisible, child) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: isContainerVisible
                      ? Container(
                          key: const ValueKey("container"),
                          height: 60,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF5DFFA6),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    onPressed: _playPreviousTrack,
                                    icon: const Icon(
                                      CupertinoIcons.chevron_back,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  ValueListenableBuilder<bool>(
                                    valueListenable: isPlayingNotifier,
                                    builder: (context, isPlaying, child) {
                                      return IconButton(
                                        onPressed: _togglePlayPause,
                                        icon: Icon(
                                          isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    onPressed: _playNextTrack,
                                    icon: const Icon(
                                      CupertinoIcons.chevron_forward,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await _player.stop();
                                      isPlayingNotifier.value = false;
                                      isContainerVisibleNotifier.value = false;
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    tracks[currentTrackIndex]['name']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isVolumeVisible = !isVolumeVisible;
                                      });
                                    },
                                    icon: Icon(
                                      isVolumeVisible
                                          ? Icons.volume_up
                                          : Icons.volume_off,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    thumbColor: Colors.transparent,
                                    overlayColor: Colors.transparent,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 0),
                                    trackHeight: 2.0,
                                  ),
                                  child: Slider(
                                    value: currentPosition.inSeconds
                                        .toDouble()
                                        .clamp(
                                            0.0,
                                            totalDuration.inSeconds
                                                .toDouble()),
                                    max: totalDuration.inSeconds.toDouble(),
                                    min: 0.0,
                                    onChanged: (value) async {
                                      final newPosition =
                                          Duration(seconds: value.toInt());
                                      await _player.seek(newPosition);
                                    },
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                );
              },
            ),
          ),
          if (isVolumeVisible)
            Row(
              children: [
                const SizedBox(width: 100),
                SizedBox(
                  width: 60,
                  height: 100,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) async {
                        setState(() {
                          volume = value;
                        });
                        await _player.setVolume(volume);
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    isPlayingNotifier.dispose();
    isContainerVisibleNotifier.dispose();
    _player.dispose();
    super.dispose();
  }
}
