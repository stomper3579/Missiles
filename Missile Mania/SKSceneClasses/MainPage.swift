//
//  MainPage.swift
//  StopTheMissiles
//
//  Created by Tyler Brady on 10/20/17.
//  Copyright © 2017 The App Men. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit
import ARKit
import AVFoundation
import UIKit

class MainPage: SKScene {
    
    let defaults:UserDefaults = UserDefaults.standard
    private var scoreLabel: SKLabelNode?
    private var mainTitle1: SKLabelNode?
    private var mainTitle2: SKLabelNode?
    private var highScoreLabel: SKLabelNode?
    private var PlayButton: SKLabelNode?
    private var mainTitleBG1: SKLabelNode?
    private var mainTitleBG2: SKLabelNode?
    private var highScoreLabelBG: SKLabelNode?
    private var scoreLabelBG: SKLabelNode?
    private var player: AVAudioPlayer?
    
    var auth = false
    
    //private var textView: SKMultilineLabel?
    
    override func didMove(to view: SKView) {
        print("Main Page has been displayed")
        
        scoreLabel = self.childNode(withName: "HighScoreText") as? SKLabelNode!
        mainTitle1 = self.childNode(withName: "Title1") as? SKLabelNode!
        mainTitle2 = self.childNode(withName: "Title2") as? SKLabelNode!
        mainTitleBG1 = self.childNode(withName: "Title1BG") as? SKLabelNode!
        mainTitleBG2 = self.childNode(withName: "Title2BG") as? SKLabelNode!
        highScoreLabel = self.childNode(withName: "HighScoreLabel") as? SKLabelNode!
        PlayButton = self.childNode(withName: "PlayButton") as? SKLabelNode!
        highScoreLabelBG = self.childNode(withName: "HighScoreLabelBG") as? SKLabelNode!
        scoreLabelBG = self.childNode(withName: "HighScoreTextBG") as? SKLabelNode!
        
        mainTitle1?.fontName = "BlackOpsOne-Regular"
        mainTitleBG1?.fontName = "BlackOpsOne-Regular"
        mainTitle2?.fontName = "BlackOpsOne-Regular"
        mainTitleBG2?.fontName = "BlackOpsOne-Regular"
        highScoreLabel?.fontName = "BlackOpsOne-Regular"
        scoreLabel?.fontName = "BlackOpsOne-Regular"
        PlayButton?.fontName = "BlackOpsOne-Regular"
        scoreLabelBG?.fontName = "BlackOpsOne-Regular"
        highScoreLabelBG?.fontName = "BlackOpsOne-Regular"
        /*
        if let highScore = defaults.integer(forKey: "highscore") as? Int {
            print("main page score is: \(highScore)")
            scoreLabel?.text = "\(highScore)"
            scoreLabelBG?.text = "\(highScore)"
        } else {
            print("main page no high score so set new one")
            scoreLabel?.text = "0"
            scoreLabelBG?.text = "0"
            
            defaults.set(0, forKey: "highscore")
            defaults.synchronize()
        }
        */
        playMusic()
        
        
        
    }
    
    func updateScore() {
        if let highScore = defaults.integer(forKey: "highscore") as? Int {
            print("main page score is: \(highScore)")
            scoreLabel?.text = "\(highScore)"
            scoreLabelBG?.text = "\(highScore)"
        } else {
            print("main page no high score so set new one")
            scoreLabel?.text = "0"
            scoreLabelBG?.text = "0"
            
            defaults.set(0, forKey: "highscore")
            defaults.synchronize()
        }
    }
    
    func playMusic() {
        guard let url = Bundle.main.url(forResource: "ingame", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            
            guard let player = player else { return }
            player.numberOfLoops = -1
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func askForCameraPermission(completionHandler: @escaping (_ granted: Bool)->Void) {
        //let mediaType = AVMediaType.videoAVMediaType.video
        let mediaType = AVMediaType.video
        AVCaptureDevice.requestAccess(for: mediaType) {
            (granted) in
            if granted == true {
                print("Granted access to \(mediaType)" )
            } else {
                print("Not granted access to \(mediaType)")
            }
            completionHandler(granted)
        }
    }
    
    
    func permissionPrimeCameraAccess() {
        let alert = UIAlertController( title: "\"<Your App>\" Would Like To Access the Camera", message: "<Your App> would like to access your Camera so that you can <customer benefit>.", preferredStyle: .alert )
        let allowAction = UIAlertAction(title: "Allow", style: .default, handler: { (alert) -> Void in
            
        })
        alert.addAction(allowAction)
        let declineAction = UIAlertAction(title: "Not Now", style: .cancel) { (alert) in
            //Analytics.track(event: .permissionsPrimeCameraCancelled)
        }
        alert.addAction(declineAction)
        
        //present(alert, animated: true, completion: nil)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        for touch in touches {
            
            let location = touch.location(in: self);
            
            if nodes(at: location)[0].name == "PlayButton" {
                
                
                let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
                print("auth status is \(authStatus.rawValue)")
                
                if authStatus == .notDetermined {
                    AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                        if response {
                            //access granted
                            self.auth = true
                            print("access granted")
                            self.startGame()
                            
                        } else {
                            self.auth = false
                            
                        }
                    }
                }
                else if authStatus == .denied {
                    print("no auth")
                    let alertController = UIAlertController(title: "Error", message: "App needs permission to access camera", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                        //Analytics.track(event: .permissionsPrimeCameraNoCamera)
                    })
                    alertController.addAction(defaultAction)
                    
                    let vc = self.view?.window?.rootViewController
                    if vc?.presentedViewController == nil {
                        vc?.present(alertController, animated: true, completion: nil)
                    }
                }
                else if authStatus == .authorized {
                    let vc = MissileLaunchViewController() //your view controller
                    let currentViewController:UIViewController=UIApplication.shared.keyWindow!.rootViewController!
                    
                    //currentViewController.performSegue(withIdentifier: "toGame", sender: self)
                    currentViewController.present(vc, animated: true, completion: nil)
                }
             
            }
            
        }
        
        
    }
    
    func startGame() {
        DispatchQueue.main.async {
            let vc = MissileLaunchViewController() //your view controller
            let currentViewController:UIViewController=UIApplication.shared.keyWindow!.rootViewController!
            
            //currentViewController.performSegue(withIdentifier: "toGame", sender: self)
            currentViewController.present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
}
