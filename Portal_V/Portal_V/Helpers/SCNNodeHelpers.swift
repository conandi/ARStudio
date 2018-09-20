//
//  SCNNodeHelpers.swift
//  Portal
//
//  Created by Namrata Bandekar on 2018-05-17.
//  Copyright © 2018 Namrata Bandekar. All rights reserved.
//

import Foundation
import SceneKit

let SURFACE_LENGTH: CGFloat = 3.0
let SURFACE_HEIGHT: CGFloat = 0.2
let SURFACE_WIDTH: CGFloat = 3.0

let SCALEX: Float = 2.0
let SCALEY: Float = 2.0

let WALL_WIDTH: CGFloat = 0.2
let WALL_HEIGHT: CGFloat = 3.0
let WALL_LENGTH: CGFloat = 3.0

func createPlaneNode(center: vector_float3, extent:vector_float3) -> SCNNode {
    let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = UIColor.yellow.withAlphaComponent(0.4)
    plane.materials = [planeMaterial]
    let planNode = SCNNode(geometry: plane)
    planNode.position = SCNVector3Make(center.x, 0, center.z)
    planNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    return planNode
}

func updatePlaneNode(_ node: SCNNode, center: vector_float3, extent: vector_float3) {
    let geometry = node.geometry as? SCNPlane
    geometry?.width = CGFloat(extent.x)
    geometry?.height = CGFloat(extent.z)
    node.position = SCNVector3Make(center.x, 0, center.z)
}

func repeatTexture(geometry: SCNGeometry, scaleX: Float, scaleY: Float) {
    
    geometry.firstMaterial?.diffuse.wrapS = SCNWrapMode.repeat
    geometry.firstMaterial?.selfIllumination.wrapS = SCNWrapMode.repeat
    geometry.firstMaterial?.normal.wrapS = SCNWrapMode.repeat
    geometry.firstMaterial?.specular.wrapS = SCNWrapMode.repeat
    geometry.firstMaterial?.emission.wrapS = SCNWrapMode.repeat
    geometry.firstMaterial?.roughness.wrapS = SCNWrapMode.repeat

    geometry.firstMaterial?.diffuse.wrapT = SCNWrapMode.repeat
    geometry.firstMaterial?.selfIllumination.wrapT = SCNWrapMode.repeat
    geometry.firstMaterial?.normal.wrapT = SCNWrapMode.repeat
    geometry.firstMaterial?.specular.wrapT = SCNWrapMode.repeat
    geometry.firstMaterial?.emission.wrapT = SCNWrapMode.repeat
    geometry.firstMaterial?.roughness.wrapT = SCNWrapMode.repeat

    geometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
    geometry.firstMaterial?.selfIllumination.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
    geometry.firstMaterial?.normal.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
    geometry.firstMaterial?.specular.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
    geometry.firstMaterial?.emission.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
    geometry.firstMaterial?.roughness.contentsTransform = SCNMatrix4MakeScale(scaleX, scaleY, 0)
}

func makeOuterSurfaceNode(width: CGFloat, height: CGFloat, length: CGFloat) -> SCNNode {
    let outerSurface = SCNBox(width: SURFACE_WIDTH, height: SURFACE_HEIGHT, length: SURFACE_LENGTH, chamferRadius: 0)
    outerSurface.firstMaterial?.diffuse.contents = UIColor.white
    outerSurface.firstMaterial?.transparency = 0.000001
    let outerSurfaceNode = SCNNode(geometry: outerSurface)
    outerSurfaceNode.renderingOrder = 10
    return outerSurfaceNode
}
