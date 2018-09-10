//
//  ViewController.swift
//  ARPokerDice
//
//  Created by conandi on 9/7/18.
//  Copyright © 2018 conandi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    // MARK: -Properties
    
    var trackingStatus: String = ""
    var diceNodes: [SCNNode] = []
    var diceCount = 5
    var diceStyle = 0
    var diceOffset: [SCNVector3] = [SCNVector3(0.0,0.0,0.0),
                                    SCNVector3(-0.05, 0.00, 0.0),
                                    SCNVector3(0.05, 0.00, 0.0),
                                    SCNVector3(-0.05, 0.05, 0.02),
                                    SCNVector3(0.05, 0.05, 0.02)]
    // MARK: -Outlets
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var styleButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    // MARK: -View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSceneView()
        initScene()
        initARSession()
        self.loadModels()
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

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Initalization
    
    func initSceneView() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showBoundingBoxes, .showWireframe, ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
    }
    
    func initScene() {
        let scene = SCNScene()
        scene.isPaused = false
        sceneView.scene = scene
        scene.lightingEnvironment.contents = "PokerDice.scnassets/Textures/Environment_CUBE.jpg"
        scene.lightingEnvironment.intensity = 2
    }
    
    func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR world tracking not supported ***")
            return
        }
        
        let config  = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.providesAudioData = false
        sceneView.session.run(config)
    }
    
    // MARK: - Button action
    @IBAction func startButtonPressed(_ sender: Any) {
        
    }
    @IBAction func styleButtonPressed(_ sender: Any) {
        
    }
    @IBAction func resetButtonPressed(_ sender: Any) {
    }
    
    // MARK: - Load Models
    func loadModels() {
        let diceScene = SCNScene(named: "PokerDice.scnassets/Models/DiceScene.scn")!
        for count in 0 ..< 5 {
            diceNodes.append(diceScene.rootNode.childNode(withName: "dice\(count)", recursively: false)!)
        }
    }
    
    // MARK: - Helper Functions
    
    func throwDiceNode(transform: SCNMatrix4, offset: SCNVector3) {
        let position = SCNVector3(transform.m41 + offset.x,
                                  transform.m42 + offset.y,
                                  transform.m43 + offset.z)
        let diceNode = diceNodes[diceStyle].clone()
        diceNode.name = "dice"
        diceNode.position = position
        sceneView.scene.rootNode.addChildNode(diceNode)
        diceCount -= 1
    }
}

extension ViewController: ARSCNViewDelegate {
    
    // MARK: -SceneKit Management
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.statusLabel.text = self.trackingStatus
        }
    }
    
    
    // MARK: - Session State Management
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            trackingStatus = "Tracking: Not Available!"
        case .normal:
            trackingStatus = "Tracking: All good!"
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                trackingStatus = "Tracking Limited due to excessive motion"
            case .insufficientFeatures:
                trackingStatus = "Tracking: Limited due to insufficient features!"
            case .initializing:
                trackingStatus = "Tracking: Initializing..."
            case .relocalizing:
                trackingStatus = "Tracking: Relocalizing..."
            }
        }
    }
    
    // MARK: - Session Error Management
    func session(_ session: ARSession, didFailWithError error: Error) {
        trackingStatus = "AR Session Failure: \(error)"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        trackingStatus = "AR Session Was Interrupted!"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        trackingStatus = "AR Session Interruption Ended"
    }
    
    // MARK: - Plane Mangement
}
