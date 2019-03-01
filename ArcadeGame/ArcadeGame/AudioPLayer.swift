//
//  AudioPLayer.swift
//  ArcadeGame
//
//  Created by Nikki Truong on 2019-02-28.
//  Copyright © 2019 PenguinExpress. All rights reserved.
//

import Foundation
import AVFoundation

struct audioPlayer {
    
    static var backgroundSoundIsMuted = false
    static var effectSoundIsMuted = false
    static var firstPlay = true
    static var backgroundPlayer = AVAudioPlayer()
    static var soundEffectPlayer = AVAudioPlayer()
    
    static func playBackgroundSound() {
        if backgroundSoundIsMuted == false && firstPlay == true {
            let AssortedMusics = NSURL(fileURLWithPath: Bundle.main.path(forResource: "The_Tesseract", ofType: "mp3")!)
            audioPlayer.backgroundPlayer = try! AVAudioPlayer(contentsOf: AssortedMusics as URL)
            audioPlayer.backgroundPlayer.prepareToPlay()
            audioPlayer.backgroundPlayer.numberOfLoops = -1
            audioPlayer.backgroundPlayer.play()
        }
    }
    
   static func playImpactSound(sound: String) {
        if effectSoundIsMuted == false  {
            let AssortedMusics = NSURL(fileURLWithPath: Bundle.main.path(forResource: sound, ofType: "mp3")!)
            audioPlayer.soundEffectPlayer = try! AVAudioPlayer(contentsOf: AssortedMusics as URL)
            audioPlayer.soundEffectPlayer.prepareToPlay()
            audioPlayer.soundEffectPlayer.numberOfLoops = 0
            audioPlayer.soundEffectPlayer.play()
        }
    }
    
    static func playBtnTappedSound() {
        if audioPlayer.effectSoundIsMuted == false  {
            audioPlayer.playImpactSound(sound: "btnTapped")
        }
    }
    
    static func muteBackgroundSound() {
        if audioPlayer.backgroundPlayer.isPlaying {
            audioPlayer.backgroundPlayer.pause()
        }
    }
    
    static func unmuteBackgroundSound() {
        audioPlayer.backgroundPlayer.play()
    }
}


//var AudioPlayer = AVAudioPlayer()
//var videoPlayer = AVPlayer()

func playBackgroundVideo() {
    
    let path = Bundle.main.path(forResource: "background", ofType: "mov")
    let videoPlayer = AVPlayer(url: NSURL(fileURLWithPath: path!) as URL)
    // let playerLayer = AVPlayerLayer(player: videoPlayer)
    // playerLayer.frame = self.view.frame
    // playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    // playerLayer.frame = self.view.bounds
    // self.view.layer.addSublayer(playerLayer)
    //videoPlayer.seek(to: CMTime.zero)
    videoPlayer.play()
    
    //        NotificationCenter.default.addObserver(self, selector: Selector(("playerItemDidReachEnd")), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem)
    
}

//    func playerItemDidReachEnd() {
//        videoPlayer.seek(to: CMTime.zero)
//    }

