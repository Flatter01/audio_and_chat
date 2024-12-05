import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioPlayerExample1 extends StatefulWidget {
  @override
  _AudioPlayerExample1State createState() => _AudioPlayerExample1State();
}

class _AudioPlayerExample1State extends State<AudioPlayerExample1> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  bool isContainerVisible = false;
  bool isVolumeVisible = false;

  Duration? totalDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  double volume = 1.0;

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
    await _loadTrack(); // Загружаем первый трек
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedPosition = prefs.getInt('audio_position');
    if (savedPosition != null) {
      await _player.seek(Duration(seconds: savedPosition));
    }

    _player.durationStream.listen((duration) {
      setState(() {
        totalDuration = duration ?? Duration.zero;
      });
    });

    _player.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });

    _player.positionStream.listen((position) {
      setState(() {
        currentPosition = position;
        _savePosition(position);
      });
    });
  }

  Future<void> _savePosition(Duration position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('audio_position', position.inSeconds);
  }

  Future<void> _playNextTrack() async {
    if (currentTrackIndex < tracks.length - 1) {
      currentTrackIndex++;
    } else {
      currentTrackIndex = 0;
    }
    await _loadTrack();
  }

  Future<void> _playPreviousTrack() async {
    if (currentTrackIndex > 0) {
      currentTrackIndex--;
    } else {
      currentTrackIndex = tracks.length - 1;
    }
    await _loadTrack();
  }

  Future<void> _loadTrack() async {
    try {
      await _player.setUrl(tracks[currentTrackIndex]['url']!);
      if (isPlaying) {
        await _player.play();
      }
    } catch (e) {
      print('Ошибка при загрузке аудио: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              if (isPlaying) {
                await _player.pause();
              } else {
                isContainerVisible = true;
                await _player.play();
              }
              setState(() {});
            },
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 40,
              color: const Color(0xFF5DFFA6),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: isContainerVisible
                  ? Container(
                      key: const ValueKey("container"),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5DFFA6),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.9,
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
                              IconButton(
                                onPressed: () async {
                                  if (isPlaying) {
                                    await _player.pause();
                                  } else {
                                    await _player.play();
                                  }
                                  setState(() {});
                                },
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                ),
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
                                  setState(() {
                                    isPlaying = false;
                                    isContainerVisible = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isVolumeVisible
                                      ? Icons.volume_up
                                      : Icons.volume_off,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isVolumeVisible = !isVolumeVisible;
                                  });
                                },
                              ),
                              Text(
                                tracks[currentTrackIndex]['name']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
                                value: currentPosition.inSeconds.toDouble(),
                                max: totalDuration?.inSeconds.toDouble() ?? 0,
                                min: 0,
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
                      .animate()
                      .slideY(begin: -1.0, end: 0.0, curve: Curves.easeOut)
                  : const SizedBox(),
            ),
          ),
          const SizedBox(height: 10),
          if (isVolumeVisible)
            Row(
              children: [
                SizedBox(width: 100),
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
    _player.dispose();
    super.dispose();
  }
}
