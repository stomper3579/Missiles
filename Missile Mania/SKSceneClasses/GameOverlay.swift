//
//  GameOverlay.swift
//  StopTheMissiles
//
//  Created by Tyler Brady on 10/18/17.
//  Copyright © 2017 The App Men. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverlay: SKScene, SKPhysicsContactDelegate {

    let lbltext = "Click anywhere on the screen to launch a rocket!  Make sure you look all around you, the missiles could start anywhere!"
    var ret: SKSpriteNode?
    var instructions: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        
        
        ret = self.childNode(withName: "reticle") as? SKSpriteNode;
        //instructions = self.childNode(withName: "instructions") as? SKSpriteNode;
        //ret?.alpha = 0
        //instructions?.alpha = 1
        
        //let textView = SKMultilineLabel(text:lbltext, labelWidth: 300, pos: CGPoint(x: 0, y: 100),
        //                                fontName: "ChalkboardSE-Regular", fontSize: CGFloat(30), fontColor:UIColor.white, alignment: SKLabelHorizontalAlignmentMode.center)
        //textView.name = "textView"
        //textView.zPosition = 3
        //self.addChild(textView)
        
    }
    
    func getReady() {
        //ret?.alpha = 1
       // instructions?.alpha = 0
    }
    

}
