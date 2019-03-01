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

    @IBOutlet weak var bgBtn: SetButtons!
    @IBOutlet weak var effBtn: SetButtons!
    
    @IBAction func backgroundSoundBtn   (_ sender: UIButton) {
        
        audioPlayer.playBtnTappedSound()
        
        if audioPlayer.backgroundSoundIsMuted == false {
            audioPlayer.backgroundSoundIsMuted = true
            audioPlayer.muteBackgroundSound()
            bgBtn.setTitle("Unmute", for: .normal)
        } else {
            audioPlayer.backgroundSoundIsMuted = false
            audioPlayer.unmuteBackgroundSound()
            bgBtn.setTitle("Mute", for: .normal)
        }
        
    }
    
    @IBAction func effectsBtn(_ sender: UIButton) {
        
        audioPlayer.playBtnTappedSound()    
        
        if audioPlayer.effectSoundIsMuted == false  {
            audioPlayer.effectSoundIsMuted = true
            effBtn.setTitle("Unmute", for: .normal)
        } else {
            audioPlayer.effectSoundIsMuted = false
            effBtn.setTitle("Mute", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
