import Felgo
import QtQuick
import QtMultimedia

Item {
  id: root

  readonly property alias music: mediaplayerLoader.item

  readonly property bool isPlaying: mediaplayerLoader.active && music.playbackState === MediaPlayer.PlayingState
  property int currentTrackIndex: -1
  property int passedTime: 0

  Loader {
    id: mediaplayerLoader

    sourceComponent: MediaPlayer {

        audioOutput: AudioOutput {}
        source: "../alarmSound01.mp3"

    }
  }

  function play() {
    timer.start()
    music.play()
  }

  function pause() {
    timer.stop()
    music.pause()
  }
}
