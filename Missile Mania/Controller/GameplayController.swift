//
//  GamePlayController.swift
//  StopTheMissiles
//
//  Created by Tyler Brady on 10/19/17.
//  Copyright © 2017 The App Men. All rights reserved.
//

import Foundation
import SpriteKit

class GameplayController {
    static let instance = GameplayController()
    private init() {}
    
    var scoreText: SKLabelNode?
    
    var score: Int = 0

    let defaults:UserDefaults = UserDefaults.standard
    
    func initializeVariables() {
    
            score = 0
            scoreText?.text = "\(score)"
    }

    func incrementScore() {
        print("up the score")
        score += 1
        scoreText?.text = "\(score)"
    }
    func resetScore() {
        score = 0
        scoreText?.text = "\(score)"

    }
    
    func gameOver() {
        
        if let highScore = defaults.integer(forKey: "highscore") as? Int {
            let currentScore = Int((scoreText?.text)!)
            //let highScore = defaults.integer(forKey: "highscore")
            print("game over score is: \(currentScore!)")
            print("game over high score is: \(highScore)")
            if currentScore! > highScore {
                defaults.set(currentScore, forKey: "highscore")
                print("game over, current is higher")
            }
            
        } else {
            print("game over no high score, time to set one")
            defaults.set(Int((scoreText?.text)!), forKey: "highscore")
        }
        defaults.synchronize()

    }
}
