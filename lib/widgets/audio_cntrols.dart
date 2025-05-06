import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioControls extends StatefulWidget {
  final String audioAssetPath;

  const AudioControls({super.key, required this.audioAssetPath});

  @override
  State<AudioControls> createState() => _AudioControlsState();
}

class _AudioControlsState extends State<AudioControls> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadAudio();
  }

  Future<void> _loadAudio() async {
    try {
      await _player.setAsset(widget.audioAssetPath);
    } catch (e) {
      debugPrint("Failed to load audio: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _rewind() {
    final newPosition = _player.position - const Duration(seconds: 5);
    _player.seek(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  void _forward() {
    final newPosition = _player.position + const Duration(seconds: 5);
    _player.seek(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scrwidth = size.width;
    final scrheight = size.height;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.replay_5, size: scrwidth * 0.06),
          onPressed: _rewind,
        ),
        SizedBox(width: scrwidth * 0.05),
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            final playing = state?.playing ?? false;
            final processing = state?.processingState;

            if (processing == ProcessingState.loading ||
                processing == ProcessingState.buffering) {
              return const CircularProgressIndicator();
            }

            return IconButton(
              icon: Icon(playing ? Icons.pause : Icons.play_arrow,
                  size: scrwidth * 0.06),
              onPressed: playing ? _player.pause : _player.play,
            );
          },
        ),
        SizedBox(width: scrwidth * 0.05),
        IconButton(
          icon: Icon(Icons.forward_5, size: scrwidth * 0.06),
          onPressed: _forward,
        ),
      ],
    );
  }
}
