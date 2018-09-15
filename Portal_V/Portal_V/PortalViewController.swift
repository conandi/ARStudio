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
    var debugPlanes: [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLabels()
        runSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
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
        sceneView?.session.run(configuration)
        
        #if DEBUG
            sceneView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        #endif
        sceneView.delegate = self
    }
}

extension PortalViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                #if DEBUG
                let debugPlaneNode = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
                node.addChildNode(debugPlaneNode)
                #endif
                self.messageLabel?.text = "Tap on the detected horizontal plane to place the portal"
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, node.childNodes.count > 0 {
                updatePlaneNode(node.childNodes[0], center: planeAnchor.center, extent: planeAnchor.extent)
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
