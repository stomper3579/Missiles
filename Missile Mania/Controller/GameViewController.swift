//
//  ViewController.swift
//  StopTheMissiles
//
//  Created by Tyler Brady on 9/30/17.
//  Copyright © 2017 The App Men. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class GameViewController: UIViewController {

    var theScene: MainPage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //To Do
        //fire missile at slightly less angle
        //bazooka-ish overlay
        //first time opening game instructions overlay
        //test missile speeds
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = MainPage(fileNamed: "MainPage") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                theScene = scene
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            //view.showsFPS = true
            //view.showsNodeCount = true
            //view.showsPhysics = true;
        }
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("GVC appeared!!")
        
        theScene!.updateScore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
}
