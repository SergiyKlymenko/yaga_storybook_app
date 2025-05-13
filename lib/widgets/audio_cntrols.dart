import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import 'forest_audio_player.dart';

class AudioControls extends StatefulWidget {
  final String audioAssetPath;

  const AudioControls({Key? key, required this.audioAssetPath})
      : super(key: key);

  @override
  State<AudioControls> createState() => _AudioControlsState();
}

class _AudioControlsState extends State<AudioControls> {
  late final AudioPlayer _player;
  bool _loaded = false, _hasError = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // Завантажуємо asset так само просто, як у pageFlipPlayer
    _player.setAsset(widget.audioAssetPath).then((_) {
      debugPrint('✅ Audio asset loaded: ${widget.audioAssetPath}');
      setState(() => _loaded = true);
    }).catchError((e) {
      debugPrint('❌ Failed to load audio asset: $e');
      setState(() => _hasError = true);
    });

    // mute/unmute background forest sound
    _player.playingStream.listen((isPlaying) {
      if (isPlaying) {
        ForestAudioPlayer().mute();
      } else {
        ForestAudioPlayer().unmute();
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _rewind() => _player.seek(_player.position - const Duration(seconds: 5));
  void _forward() =>
      _player.seek(_player.position + const Duration(seconds: 5));

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Text('Помилка завантаження аудіо',
          style: TextStyle(color: Colors.red));
    }

    final sz = MediaQuery.of(context).size;
    final iconSize = sz.height * 0.035;
    final gap = SizedBox(width: sz.width * 0.05);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.replay_5, size: iconSize),
          onPressed: _loaded ? _rewind : null,
        ),
        gap,
        if (!_loaded)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        else
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (_, snap) {
              final playing = snap.data?.playing ?? false;
              final proc = snap.data?.processingState;
              if (proc == ProcessingState.loading ||
                  proc == ProcessingState.buffering) {
                return SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                );
              }
              return IconButton(
                icon: Icon(playing ? Icons.pause : Icons.play_arrow,
                    size: iconSize),
                onPressed: _togglePlay,
              );
            },
          ),
        gap,
        IconButton(
          icon: Icon(Icons.forward_5, size: iconSize),
          onPressed: _loaded ? _forward : null,
        ),
      ],
    );
  }
}
