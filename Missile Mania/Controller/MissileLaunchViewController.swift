
import UIKit
import SceneKit
import ARKit
import SpriteKit
import GoogleMobileAds
import AVFoundation

enum BoxBodyType : Int {
    case bullet = 1
    case barrier = 2
    case ceiling = 4
}

class MissileLaunchViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate,
GADInterstitialDelegate {
    
    var sceneView: ARSCNView!
    var lastContactNode :SCNNode!
    let scene = SCNScene()
    var checker: Int = 0
    var shots = [SCNNode]()
    var missiles = [SCNNode]()
    var ret:SKSpriteNode?
    var instructions:SKSpriteNode?
    private var mainCamera: SKCameraNode?
    var GameOverlayScene: GameOverlay?
    var GameIntroOverlayScene: GameIntroOverlay?
    var GameOverOverlayScene: GameOverOverlay?
    var tapGestureRecognizer2: UIGestureRecognizer?
    var speedUp: Int = 0
    let defaults = UserDefaults.standard
    var wasLaunchedBefore: Bool?
    var homeOrRetry: Int = 0
    var missileIncrement: Int = 0
    var isFirstLaunch: Bool {
        return !wasLaunchedBefore!
    }
    private var explosionPlayer: AVAudioPlayer?
    private var launchPlayer: AVAudioPlayer?
    private var sirenPlayer: AVAudioPlayer?

    var interstitial: GADInterstitial!
    
    //let gc = GamePlayController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitial = createAndLoadInterstitial()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        let key = "WasLaunchedBefore"
        let wasLaunchedBefore = defaults.bool(forKey: key)
        self.wasLaunchedBefore = wasLaunchedBefore
        if !wasLaunchedBefore {
            defaults.set(true, forKey: key)
        }
        
        self.sceneView = ARSCNView(frame: self.view.frame)
        self.view.addSubview(self.sceneView)
        
        sceneView.delegate = self
        //sceneView.debugOptions = [.showPhysicsShapes]
        
        guard let launchUrl = Bundle.main.url(forResource: "cutLaunch", withExtension: "mp3") else { return }
        guard let explosionUrl = Bundle.main.url(forResource: "explosion", withExtension: "mp3") else { return }
        guard let sirenUrl = Bundle.main.url(forResource: "siren", withExtension: "mp3") else {return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            explosionPlayer = try AVAudioPlayer(contentsOf: explosionUrl)
            launchPlayer = try AVAudioPlayer(contentsOf: launchUrl)
            sirenPlayer = try AVAudioPlayer(contentsOf: sirenUrl)
        
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        sceneView.scene = scene
        self.sceneView.scene.physicsWorld.contactDelegate = self
        GameOverlayScene = GameOverlay(fileNamed: "GameOverlay")
        GameIntroOverlayScene = GameIntroOverlay(fileNamed: "GameIntroOverlay")
        GameOverlayScene?.scaleMode = .aspectFit
        GameIntroOverlayScene?.scaleMode = .aspectFit
        
       
        mainCamera = GameOverlayScene?.childNode(withName: "MainCamera") as? SKCameraNode!
        if (mainCamera != nil) {
            print("camera not null")
        } else {
            print("camera is null")
        }
        //ret?.isHidden = true
        if self.isFirstLaunch {
            sceneView.overlaySKScene = GameIntroOverlayScene
        } else {
            sceneView.overlaySKScene = GameOverlayScene
            getLabels()
            
        }
        
        registerGestureRecognizers()
        GameplayController.instance.initializeVariables()
        buildCeiling()
        
        
    }
    private func getLabels() {
        GameplayController.instance.scoreText = self.mainCamera?.childNode(withName: "ScoreText") as? SKLabelNode!
        GameplayController.instance.scoreText?.text = "0"
        
    }
    
    func playExplosion() {
        guard let player = explosionPlayer else { return }
        //player.numberOfLoops = -1
        player.play()
    }
    
    func playLaunch() {
        guard let player = launchPlayer else { return }
        //player.numberOfLoops = -1
        player.play()
    }
    
    func playSiren() {
        guard let player = sirenPlayer else { return }
        player.play()
    }
    
    private func registerGestureRecognizers() {
        
        tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(shoot))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer2!)
        
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(doStuff))
        //self.sceneView.overlaySKScene?.view?.addGestureRecognizer(tapGestureRecognizer3)
        
    }
    
    func buildCeiling() {
        let box1 = SCNBox(width: 100, height: 0.1, length: 100, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.clear
        
        box1.materials = [material]
        
        let box1Node = SCNNode(geometry: box1)
        box1Node.name = "Ceiling"
        box1Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box1Node.physicsBody?.categoryBitMask = BoxBodyType.ceiling.rawValue
        box1Node.physicsBody?.collisionBitMask = BoxBodyType.barrier.rawValue
        box1Node.physicsBody?.contactTestBitMask = BoxBodyType.barrier.rawValue
        box1Node.position = SCNVector3(0,30, 0)
        
        self.sceneView.scene.rootNode.addChildNode(box1Node)
    }
    
    func createNextMissile() {
        print("missile created")
        speedUp += 9
        print("speed up is \(speedUp)")
        if missiles.count >= 2 {
            missiles.first?.removeFromParentNode()
            missiles.remove(at: 0)
        }
        checker = 0
        let missileScene = SCNScene(named: "art.scnassets/missile-1.scn")
        
        let missile = Missile(scene: missileScene!)
        missile.name = "Missile"
        missile.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        missile.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        missile.physicsBody?.collisionBitMask = BoxBodyType.bullet.rawValue | BoxBodyType.ceiling.rawValue
        missile.physicsBody?.contactTestBitMask = BoxBodyType.bullet.rawValue | BoxBodyType.ceiling.rawValue
        missile.physicsBody?.isAffectedByGravity = false
        
        let randX = -10 + Int(arc4random_uniform(UInt32(20)))
        let randomSequenceNumber = Int(arc4random_uniform(2))
        var randZ:Int
        if randomSequenceNumber == 1 {
            randZ = (7 + Int(arc4random_uniform(UInt32(10)))) * -1
        } else {
            randZ = (7 + Int(arc4random_uniform(UInt32(10))))
        }
        if missileIncrement < 3 {
            randZ = -12
        }
        
        //missile.position = SCNVector3(0,-15,-7)          // for simulator
        missile.position = SCNVector3(randX,-15,randZ) // for production
        
        //missile.position = SCNVector3(0,0,-5)
        
        scene.rootNode.addChildNode(missile)
        
    
        guard let smokeNode = missile.childNode(withName: "smokeNode", recursively: true) else {
            fatalError("no smoke node found")
        }
        
        smokeNode.removeAllParticleSystems()
        
        let fire = SCNParticleSystem(named: "fire.scnp", inDirectory: nil)
        
        smokeNode.addParticleSystem(fire!)
        
        missile.physicsBody?.applyForce(SCNVector3(0,250+speedUp,0), asImpulse: false)
        
        missiles.append(missile)
        print("end of missile creation checker \(checker)")
        missileIncrement += 1
    }
    
    
    @objc func doStuff() {
        print("we're doing stuff")
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches")
   
    }
    
    @objc func shoot(recognizer :UIGestureRecognizer) {
        //interstitial.present(fromRootViewController: self)
        
        if sceneView.overlaySKScene == GameOverOverlayScene {
            
            let p = recognizer.location(in: sceneView)
            let p2D = GameOverOverlayScene?.convertPoint(fromView: p)
            let homeButton = GameOverOverlayScene?.childNode(withName: "HomeButton")
            let retryButton = GameOverOverlayScene?.childNode(withName: "RetryButton")

            if (homeButton?.contains(p2D!))! {
                print("Home!!")
                homeOrRetry = 0
                sirenPlayer?.stop()
                endings()
            }
            else if (retryButton?.contains(p2D!))! {
                print("Retry!!")
                homeOrRetry = 1
                sirenPlayer?.stop()
                endings()
            }
            print("game over overlay is good")
            
        } else {
            
            if self.isFirstLaunch {
                print("first launch!")
                sceneView.overlaySKScene = GameOverlayScene
                getLabels()
                
                let key = "WasLaunchedBefore"
                defaults.set(true, forKey: key)
                wasLaunchedBefore = true
                createNextMissile()
                
            }
            else {
                
                playLaunch()
                
                print("shooting")
                checker = 0
                
                if shots.count >= 3 {
                    print("found them")
                    let temp = shots.first!
                    temp.removeFromParentNode()
                    shots.remove(at: 0)
                    //temp = nil
                }
                guard let currentFrame = self.sceneView.session.currentFrame else {
                    return
                }
                
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -1.1  //this backs up the bullet
                translation.columns.3.x = 0.8
                //adding to y causes it to start from the right
                
                let bulletScene = SCNScene(named: "art.scnassets/missileBullet.scn")
                let bullet = Missile(scene: bulletScene!)
                //let missile = Missile(scene: missileScene!)
                
                bullet.name = "Bullet"
                bullet.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                bullet.physicsBody?.categoryBitMask = BoxBodyType.bullet.rawValue
                bullet.physicsBody?.collisionBitMask = BoxBodyType.barrier.rawValue
                bullet.physicsBody?.contactTestBitMask = BoxBodyType.barrier.rawValue
                bullet.physicsBody?.isAffectedByGravity = false
                bullet.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
                
                guard let smokeNode = bullet.childNode(withName: "smokeNode", recursively: true) else {
                    fatalError("no smoke node found")
                }
                
                smokeNode.removeAllParticleSystems()
                
                let fire = SCNParticleSystem(named: "fire.scnp", inDirectory: nil)
                fire?.particleSize = 0.25
                smokeNode.addParticleSystem(fire!)
                
                let force: Float = 17
                let forceVector = SCNVector3(bullet.worldFront.x * force, bullet.worldFront.y * force, bullet.worldFront.z * force)
                
                bullet.physicsBody?.applyForce(forceVector, asImpulse: true)
                //smokeNode.physicsBody?.applyForce(forceVector, asImpulse: true)
                
                self.sceneView.scene.rootNode.addChildNode(bullet)
                
                shots.append(bullet)
                
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        checker = 0
        print("contact ended")
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("beginning checker is \(checker)")
        if checker == 0 {
            print("Contact!!")
            
            
            checker = checker + 1
            
            var contactNode :SCNNode!
            print(contact.nodeA.name!)
            print(contact.nodeB.name!)
            
            if contact.nodeA.name == "Ceiling" || contact.nodeB.name == "Ceiling" {
                //game over
                Timer.scheduledTimer(timeInterval: TimeInterval(2), target: self, selector: #selector(goHome), userInfo: nil, repeats: false);
                
                endGame()
                
                print("hit the ceiling \(contact.nodeA.name!) and \(contact.nodeB.name!)")
                return
            }
            
            if contact.nodeA.name == "Bullet" {
                contact.nodeA.removeFromParentNode()
                contactNode = contact.nodeB
            } else {
                contact.nodeB.removeFromParentNode()
                contactNode = contact.nodeA
            }
            
            if self.lastContactNode != nil && self.lastContactNode == contactNode {
                return
            }
            playExplosion()
            self.lastContactNode = contactNode
            
            self.lastContactNode.physicsBody?.isAffectedByGravity = true
            
            GameplayController.instance.incrementScore()
            
            createNextMissile()
            
        }
        print("ending checker is \(checker)")
        
    }
    
    func endGame() {
        //sceneView.pause(self)
        print("end game method")
    
        playSiren()
        
        GameplayController.instance.gameOver()
        
        GameOverOverlayScene = GameOverOverlay(fileNamed: "GameOverOverlay")
        GameOverOverlayScene?.scaleMode = .aspectFit
        GameOverOverlayScene?.scaleMode = .aspectFit
        
        sceneView.overlaySKScene = GameOverOverlayScene
        
        //let overlay = SKScene(fileNamed: "overlay")
        //GameOverOverlayScene?.isUserInteractionEnabled = false
        let homeButton = GameOverOverlayScene?.childNode(withName: "HomeButton")
    
        let retryButton = GameOverOverlayScene?.childNode(withName: "RetryButton")
        homeButton?.isUserInteractionEnabled = true
        retryButton?.isUserInteractionEnabled = true
    }
    
    func adsThenHome() {
        
    }
    
    func adsThenRetry() {
        
    }
    
    func endings() {
        if interstitial.isReady {
            sceneView.session.pause()
            //numOfPlays = 0
            DispatchQueue.main.async {
                
                self.interstitial.present(fromRootViewController: self)
            }
        } else {
            print("Ad wasn't ready")
            
            if homeOrRetry == 1 {
                restart()
            } else {
                goHome()
            }
            
            //interstitial = createAndLoadInterstitial()
            
        }
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        //self.performSegue(withIdentifier: "moveScreenSegue", sender: self)
        print("ending interstitial")
        

        
    }
    
    func restart() {
        speedUp = 0
        missileIncrement = 0
        sceneView.overlaySKScene = GameOverlayScene
        GameplayController.instance.resetScore()
        for missile in missiles {
            missile.removeFromParentNode()
        }
        missiles.removeAll()

        createNextMissile()
    }
    
    @objc func goHome() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !self.isFirstLaunch {
            createNextMissile()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-4669796031389716~8992693585")
        //ca-app-pub-4669796031389716~8992693585
        // old one ca-app-pub-3940256099942544/4411468910
        
        interstitial.delegate = self
        let request = GADRequest()
        
        //request.testDevices = ["155f0d7e3dd0621b142d87cefc2b8426"]
        //request.testDevices = [kGADSimulatorID]
        //https://googleads.g.doubleclick.net/mads/static/sdk/native/sdk-core-v40.html
        interstitial.load(request)
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
        
        if homeOrRetry == 1 {
            restart()
        } else {
            goHome()
        }
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        goHome()
    }
    
}


