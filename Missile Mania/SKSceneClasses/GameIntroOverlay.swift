//
//  GameIntroOverlay.swift
//  StopTheMissiles
//
//  Created by Tyler Brady on 11/15/17.
//  Copyright © 2017 The App Men. All rights reserved.
//

import Foundation
import SpriteKit

class GameIntroOverlay: SKScene, SKPhysicsContactDelegate {
    
    let lbltext = "Click anywhere on the screen to shoot!  Make sure you look all around you, the first 3 will start out in front but then they could come from anywhere!"
    var instructions: SKSpriteNode?

    override func didMove(to view: SKView) {
        
        
        instructions = self.childNode(withName: "instructions") as? SKSpriteNode;
        //instructions?.alpha = 1
        
        let textView = SKMultilineLabel(text:lbltext, labelWidth: 300, pos: CGPoint(x: 0, y: 100),
                                        fontName: "ChalkboardSE-Regular", fontSize: CGFloat(30), fontColor:UIColor.white, alignment: SKLabelHorizontalAlignmentMode.center)
        textView.name = "textView"
        textView.zPosition = 3
        self.addChild(textView)
        
    }

}