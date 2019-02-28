//
//  SttingsViewController.swift
//  ArcadeGame
//
//  Created by Nikki Truong on 2019-02-28.
//  Copyright © 2019 PenguinExpress. All rights reserved.
//

import UIKit
import AVFoundation

class SettingsViewController: UIViewController {

    @IBAction func backgroundSoundBtn   (_ sender: UIButton) {
        if audioPlayer.backgroundSoundIsMuted == false {
            audioPlayer.backgroundSoundIsMuted = true
            audioPlayer.muteBackgroundSound()
        } else {
            audioPlayer.backgroundSoundIsMuted = false
            audioPlayer.unmuteBackgroundSound()
        }
        
    }
    
    @IBAction func effectsBtn(_ sender: UIButton) {
        if audioPlayer.effectSoundIsMuted == false  {
            audioPlayer.effectSoundIsMuted = true
            audioPlayer.muteEffectSound()
        } else {
            audioPlayer.effectSoundIsMuted = false
            audioPlayer.unmuteEffectSound()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func fadeAllPlayers() {


    }

}
