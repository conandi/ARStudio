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

enum GameState: Int16 {
    case detectSurface
    case pointToSurface
    case swipeToPlay
}

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
    var focusNode: SCNNode!
    var gameState: GameState = .detectSurface
    var statusMessage: String = ""
    var focusPoint: CGPoint!
    
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
    
    func updateStatus() {
        switch gameState {
        case .detectSurface:
            statusMessage = "Scan entire table surface... \nHit START when ready!"
        case .pointToSurface:
            statusMessage = "Point ar designated surface fist!"
        case .swipeToPlay:
            statusMessage = "Swipe UP throw!\nTap on dice to collect it again."
        }
        self.statusLabel.text = trackingStatus != "" ? "\(trackingStatus)" : "\(statusMessage)"
    }
    
    @objc func orientationChanged() {
        focusPoint = CGPoint(x: view.center.x,
                             y: view.center.y + view.center.y*0.25)
    }
    
    // MARK: - Initalization
    
    func initSceneView() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
//        sceneView.debugOptions = [.showBoundingBoxes, .showWireframe, ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y*0.25)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.orientationChanged),
                                               name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
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
        config.planeDetection = .horizontal
        sceneView.session.run(config)
    }
    
    // MARK: - Button action
    @IBAction func startButtonPressed(_ sender: Any) {
        
    }
    @IBAction func styleButtonPressed(_ sender: Any) {
        diceStyle = diceStyle >= 4 ? 0 : diceStyle + 1
    }
    @IBAction func resetButtonPressed(_ sender: Any) {
    }
    
    @IBAction func swipeUPGestureHandler(_ sender: Any) {
        guard let frame  = self.sceneView.session.currentFrame else { return }
        
        for count in 0 ..< diceCount {
            throwDiceNode(transform: SCNMatrix4(frame.camera.transform), offset: diceOffset[count])
        }
    }
    
    // MARK: - Load Models
    func loadModels() {
        let diceScene = SCNScene(named: "PokerDice.scnassets/Models/DiceScene.scn")!
        for count in 0 ..< 5 {
            diceNodes.append(diceScene.rootNode.childNode(withName: "dice\(count)", recursively: false)!)
        }
        let focuScene = SCNScene(named: "PokerDice.scnassets/Models/FocusScene.scn")!
        focusNode = focuScene.rootNode.childNode(withName: "focus", recursively: false)!
        sceneView.scene.rootNode.addChildNode(focusNode)
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
//        diceCount -= 1
    }
    
    func createARPlaneNode(planeAnchor: ARPlaneAnchor, color: UIColor) -> SCNNode {
        let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                     height: CGFloat(planeAnchor.extent.z))
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = "PokerDice.scnassets/Textures/Surface_DIFFUSE.png"
        planeGeometry.materials = [planeMaterial]
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        return planeNode
    }
    
    func updateARPlaneNode(planeNode: SCNNode, planeAchor: ARPlaneAnchor) {
        let planeGeometry = planeNode.geometry as! SCNPlane
        planeGeometry.width = CGFloat(planeAchor.extent.x)
        planeGeometry.height = CGFloat(planeAchor.extent.z)
        planeNode.position = SCNVector3Make(planeAchor.center.x, 0, planeAchor.center.z)
    }
    
    func updateFocusNode() {
        let results = self.sceneView.hitTest(self.focusPoint, types: [.existingPlaneUsingExtent])
        if results.count == 1 {
            if let match = results.first {
                let t = match.worldTransform
                self.focusNode.position = SCNVector3(x: t.columns.3.x,
                                                     y: t.columns.3.y,
                                                     z: t.columns.3.z)
                self.gameState = .swipeToPlay
            }
        } else {
            self.gameState = .pointToSurface
        }
    }
    
    func removeARPlaneNode(node: SCNNode) {
        
    }
}

extension ViewController: ARSCNViewDelegate {
    
    // MARK: -SceneKit Management
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateStatus()
            self.updateFocusNode()
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            let planeNode = self.createARPlaneNode(planeAnchor: planeAnchor,
                                                   color: UIColor.yellow.withAlphaComponent(0.5))
            node.addChildNode(planeNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.updateARPlaneNode(planeNode: node.childNodes[0], planeAchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.removeARPlaneNode(node: node.childNodes[0])
        }
    }
}
