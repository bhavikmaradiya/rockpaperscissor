import 'package:audioplayers/audioplayers.dart';
import 'package:rockpaperscissor/const/assets.dart';

class SoundUtils {
  static final AudioPlayer _player = AudioPlayer();

  static void playButtonClick() {
    _player.play(
      AssetSource(
        Assets.buttonClickSound,
      ),
      position: const Duration(
        milliseconds: 0,
      ),
    );
  }

  static void playSelectionClick() {
    _player.play(
      AssetSource(
        Assets.selectionSound,
      ),
      position: const Duration(
        milliseconds: 0,
      ),
    );
  }
}
