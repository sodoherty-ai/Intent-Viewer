//
//  ARViewController.swift
//  Intent Viewer
//
//  Created by Simon O'Doherty on 28/02/2021.
//

import UIKit
import RealityKit
import ARKit
import Assistant
import ChameleonFramework

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var intents = [IntentData]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.white
        
        generateNetworkGraph()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
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

}

extension ARViewController {
    
    func generateNetworkGraph() {
        let root: (Float, Float, Float) = (0, 0, -0.5)
        
        createNode("Root Node", x: root.0, y: root.1, z: root.2, color: UIColor.flatWatermelon())
        
        var intentPoints = getPointsOnSphere(intents.count)
        var idx = 0

        for i in intentPoints {
            intentPoints[idx] = scaleDown(root, i, 2)

            let ii = intentPoints[idx]
            createNode(intents[idx].intent!, x: ii.0, y: ii.1, z: ii.2, color: UIColor.flatRed())
            createEdge(root, ii, color: UIColor.flatOrange())
            
            var examplePoints = getPointsOnSphere(intents[idx].examples!.count, root: ii)
            var eidx = 0
            for e in examplePoints {
                examplePoints[eidx] = scaleDown(e, ii, 8)
                let ee = examplePoints[eidx]
                createText(intents[idx].examples![eidx], x: ee.0, y: ee.1, z: ee.2, color: UIColor.flatLime())
                createEdge(ii, ee, color: UIColor.flatMint())
                eidx += 1
            }
            idx += 1
        }
    }
    
    func scaleDown(_ s: (Float,Float,Float), _ e: (Float,Float,Float), _ scale: Float) -> (Float,Float,Float) {
        let x = (e.0 - s.0) / scale
        let y = (e.1 - s.1) / scale
        let z = (e.2 - s.2) / scale
        
        return (e.0 - x, e.1 - y, e.2 - z)
    }
    
    func createEdge(_ start: (Float, Float, Float), _ end: (Float, Float, Float), radius: CGFloat = 0.01, height: CGFloat = 0.01, color: UIColor ) {
        
        let line = lineBetweenNodes(
            SCNVector3(start.0, start.1, start.2),
            SCNVector3(end.0, end.1, end.2),
            sceneView.scene,
            color
        )
        sceneView.scene.rootNode.addChildNode(line)
        
    }
    
    // Thanks to: https://gist.github.com/GrantMeStrength/62364f8a5d7ea26e2b97b37207459a10#gistcomment-3192863
    // Why Apple doesn't have a 3D line draw is beyond me.
    func lineBetweenNodes(_ positionA: SCNVector3, _ positionB: SCNVector3, _ inScene: SCNScene, _ color: UIColor) -> SCNNode {
            let vector = SCNVector3(positionA.x - positionB.x, positionA.y - positionB.y, positionA.z - positionB.z)
            let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
            let midPosition = SCNVector3 (x:(positionA.x + positionB.x) / 2, y:(positionA.y + positionB.y) / 2, z:(positionA.z + positionB.z) / 2)

            let lineGeometry = SCNCylinder()
            lineGeometry.radius = 0.002
            lineGeometry.height = CGFloat(distance)
            lineGeometry.radialSegmentCount = 5
            lineGeometry.firstMaterial!.diffuse.contents = color

            let lineNode = SCNNode(geometry: lineGeometry)
            lineNode.position = midPosition
            lineNode.look (at: positionB, up: inScene.rootNode.worldUp, localFront: lineNode.worldUp)
            return lineNode
    }
    
    // This is a port from Python method: https://stackoverflow.com/a/16128461/1167890
    func getPointsOnSphere(_ numberOfPoints: Int, root: (Float, Float, Float) = (0,0,0)) -> [(Float, Float, Float)]{
        let dlong: Float = .pi * (3.0 - sqrt(5.0) )
        let dz: Float = 2.0 / Float(numberOfPoints)
        var long: Float = 0.0
        var z: Float = 1.0 - dz / 2.0
        
        var pointsOnSphere = [(Float, Float, Float)]()
        
        for _ in 0..<numberOfPoints {
            let r = sqrt(1.0 - z * z)
            let pointNew = (cos(long) * r, sin(long) * r, z)
            
            pointsOnSphere.append(
                (pointNew.0 + root.0, pointNew.1 + root.1, pointNew.2 + root.2)
            )
            z = z - dz
            long = long + dlong
        }
        
        return pointsOnSphere
    }
    
    func createNode(_ text: String, x: Float, y: Float, z: Float, color: UIColor, radius: CGFloat = 0.02) {
        let sphere = SCNSphere(radius: radius)
        sphere.firstMaterial?.diffuse.contents = color
        
        let node = SCNNode()
        node.position = SCNVector3(x, y, z)
        node.geometry = sphere
        
        let sphereText = SCNText(string: text, extrusionDepth: 1.0)
        
        let textNode = SCNNode()
        textNode.position = SCNVector3(x: x - Float(radius), y: y + Float(radius), z: z)
        textNode.scale = SCNVector3(0.001, 0.001, 0.001)
        textNode.geometry = sphereText
        
        sceneView.scene.rootNode.addChildNode(node)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func createText(_ text: String, x: Float, y: Float, z: Float, color: UIColor, radius: CGFloat = 0.02) {
        let arText = SCNText(string: text, extrusionDepth: 1.0)
        arText.firstMaterial?.diffuse.contents = [color]
        
        let textNode = SCNNode()
        textNode.position = SCNVector3(x, y, z)
        textNode.scale = SCNVector3(0.001, 0.001, 0.001)
        textNode.geometry = arText

        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
