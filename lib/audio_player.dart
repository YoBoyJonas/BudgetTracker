import 'package:audioplayers/audioplayers.dart';
import 'package:budget_tracker/globals/globals.dart';

class Audio {
  final AudioPlayer _player = AudioPlayer();

  void playSoundEffect(SoundEffect effect) {
    if (soundEnabled) {
      String fileName = _convertSoundEffectToString(effect);
      _player.play(AssetSource('audio/$fileName'));
    }
  }

  String _convertSoundEffectToString(SoundEffect effect) {
    String fileName;

    switch (effect) {
      case SoundEffect.buttonClick:
        fileName = "click.mp3";
        break;
      case SoundEffect.tabTransition:
        fileName = "transition.mp3";
        break;
      default:
        fileName = "unknown";
        break;
    }

    return fileName;
  }
}
