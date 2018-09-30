//
//  ViewController.swift
//  Portal_V
//
//  Created by DI, JIAJIA on 9/14/18.
//  Copyright © 2018 DI, JIAJIA. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class PortalViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var sessionStateLabel: UILabel!
    @IBOutlet weak var crosshair: UIView!
    var debugPlanes: [SCNNode] = []
    var portalNode: SCNNode? = nil
    var isPortalPlaced = false
    var viewCenter: CGPoint {
        let viewBounds = view.bounds
        return CGPoint(x: viewBounds.width/2.0, y: viewBounds.height/2.0)
    }
    let POSITION_Y: CGFloat = -WALL_HEIGHT*0.5
    let POSITION_Z: CGFloat = -SURFACE_LENGTH*0.5
    
    let DOOR_WIDTH:CGFloat = 1.0
    let DOOR_HEIGHT:CGFloat = 2.4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLabels()
        runSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - Actions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let hit = sceneView?.hitTest(viewCenter, types: [.existingPlaneUsingExtent]).first {
            sceneView?.session.add(anchor: ARAnchor.init(transform: hit.worldTransform))
        }
    }
    
    // MARK: -Helper methods
    func resetLabels() {
        messageLabel.alpha = 1.0
        messageLabel.text = "Move the phone around and allow the app to find a plane. You will see a yellow horizontal plane."
        sessionStateLabel.alpha = 0.0
        sessionStateLabel.text = ""
    }
    
    func showMessage(_ message: String, label: UILabel, seconds: Double) {
        label.text = message
        label.alpha = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if label.text == message {
                label.text = ""
                label.alpha = 0
            }
        }
    }
    
    func removeAllNodes() {
        removeDebugPlane()
        self.portalNode?.removeFromParentNode()
        self.isPortalPlaced = false
    }
    
    func removeDebugPlane() {
        for debugPlaneNode in self.debugPlanes {
            debugPlaneNode.removeFromParentNode()
        }
        self.debugPlanes = []
    }
    
    func runSession() {
        let configuration = ARWorldTrackingConfiguration.init()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        sceneView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        #if DEBUG
            sceneView?.debugOptions = [SCNDebugOptions.showFeaturePoints]
        #endif
        sceneView.delegate = self
    }
    
    func addDoorWay(node: SCNNode) {
        let halfWallLength: CGFloat = WALL_LENGTH * 0.5
        let frontHalfWallLength: CGFloat = (WALL_LENGTH - DOOR_WIDTH) * 0.5
        
        let rightDoorSideNode = makeWallNode(length: frontHalfWallLength)
        rightDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        rightDoorSideNode.position = SCNVector3(halfWallLength-0.5*DOOR_WIDTH,
                                                POSITION_Y+WALL_HEIGHT*0.5,
                                                POSITION_Z+SURFACE_LENGTH*0.5)
        node.addChildNode(rightDoorSideNode)
        
        let leftDoorSideNode = makeWallNode(length: frontHalfWallLength)
        leftDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        leftDoorSideNode.position = SCNVector3(-halfWallLength+0.5*frontHalfWallLength,
                                               POSITION_Y+WALL_HEIGHT*0.5,
                                               POSITION_Z+SURFACE_LENGTH*0.5)
        node.addChildNode(leftDoorSideNode)
        
        let aboveDoorNode = makeWallNode(length: DOOR_WIDTH,
                                         height: WALL_HEIGHT - DOOR_HEIGHT)
        aboveDoorNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        aboveDoorNode.position =
            SCNVector3(0,
                       POSITION_Y+(WALL_HEIGHT-DOOR_HEIGHT)*0.5+DOOR_HEIGHT,
                       POSITION_Z+SURFACE_LENGTH*0.5)
        node.addChildNode(aboveDoorNode)
    }
    
    func placeLightSource(rootNode: SCNNode) {
        let light = SCNLight()
        light.intensity = 10
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0,
                                        POSITION_Y+WALL_HEIGHT, POSITION_Z)
        rootNode.addChildNode(lightNode)
        
    }
    
    func makePoral() -> SCNNode {
        let portal = SCNNode()
        
        let floorNode = makeFloorNode()
        floorNode.position = SCNVector3(0, POSITION_Y, POSITION_Z)
        portal.addChildNode(floorNode)
        
        let ceilingNode = makeCeilingNode()
        ceilingNode.position = SCNVector3(0, POSITION_Y + WALL_HEIGHT, POSITION_Z)
        portal.addChildNode(ceilingNode)
        
        let farWallNode = makeWallNode()
        farWallNode.eulerAngles = SCNVector3(0, 90.0.degreesToRadians, 0)
        farWallNode.position = SCNVector3(0,
                                          POSITION_Y+WALL_HEIGHT*0.5,
                                          POSITION_Z-SURFACE_LENGTH*0.5)
        portal.addChildNode(farWallNode)
        
        let rightSideWallNode = makeWallNode(maskLowerSide: true)
        rightSideWallNode.eulerAngles = SCNVector3(0, 180.0.degreesToRadians, 0)
        rightSideWallNode.position = SCNVector3(WALL_LENGTH*0.5,
                                                POSITION_Y+WALL_HEIGHT*0.5,
                                                POSITION_Z)
        portal.addChildNode(rightSideWallNode)
        
        let leftSideWallNode = makeWallNode(maskLowerSide: true)
        leftSideWallNode.position = SCNVector3(-WALL_LENGTH*0.5,
                                               POSITION_Y+WALL_HEIGHT*0.5,
                                               POSITION_Z)
        portal.addChildNode(leftSideWallNode)
        addDoorWay(node: portal)
        placeLightSource(rootNode: portal)
        return portal
    }
}

extension PortalViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, !self.isPortalPlaced {
                #if DEBUG
                    let debugPlaneNode = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
                    node.addChildNode(debugPlaneNode)
                    self.debugPlanes.append(debugPlaneNode)
                #endif
                self.messageLabel.alpha = 1.0
                self.messageLabel.text = """
                Tap on the detected \
                horizontal plane to place the portal
                """
            } else if !self.isPortalPlaced {
                self.portalNode = self.makePoral()
                if let protal = self.portalNode {
                    node.addChildNode(protal)
                    self.isPortalPlaced = true
                    self.removeDebugPlane()
                    self.sceneView?.debugOptions = []
                    DispatchQueue.main.async {
                        self.messageLabel.text = ""
                        self.messageLabel.alpha = 0.0
                    }
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, node.childNodes.count > 0, !self.isPortalPlaced {
                updatePlaneNode(node.childNodes[0], center: planeAnchor.center, extent: planeAnchor.extent)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            if let _ = self.sceneView?.hitTest(self.viewCenter, types: [.existingPlaneUsingExtent]).first {
                self.crosshair.backgroundColor = .green
            } else {
                self.crosshair.backgroundColor = .lightGray
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let label = self.sessionStateLabel else { return }
        showMessage(error.localizedDescription, label: label, seconds: 3)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        guard let label = self.sessionStateLabel else { return }
        showMessage("Session Interrupted", label: label, seconds: 3)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        guard let label = self.sessionStateLabel else { return }
        showMessage("Session resumed", label: label, seconds: 3)
        DispatchQueue.main.async {
            self.removeAllNodes()
            self.resetLabels()
        }
        runSession()
    }
}
