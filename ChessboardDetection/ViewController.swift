//
//  ViewController.swift
//  ChessboardDetection
//
//  Created by Rahul Sarathy on 2/1/19.
//  Copyright © 2019 Rahul Sarathy. All rights reserved.
//

import UIKit
import ARKit

let MARKER_SIZE_IN_METERS : CGFloat = 0.035;


class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var mainImage: UIImageView!
    
    
    var showCV: Bool = false
    var lastDistance : Float! = nil
    
    var lastPos : SCNVector3! = nil
    var lastFoundPos : SCNVector3! = nil
    var lastFoundxDir : SCNVector3! = nil
    var lastFoundRotMat : SCNMatrix4! = nil
    

    var ballNode : SCNNode! = nil

    
    var displayLink: CADisplayLink?
    
    override func viewDidLoad() {
        print("view did load")
        super.viewDidLoad()
        
        sceneView.session.delegate = self
        
        self.useArKit()
        
        self.ballNode = getBall(color: UIColor.green.withAlphaComponent(0.8), radius: 0.005)
        self.sceneView.scene.rootNode.addChildNode(ballNode)

    }
    
    private func useArKit() {
        let configuration = ARWorldTrackingConfiguration()
        self.sceneView.session.run(configuration)
    }
    
    @IBAction func goTOOpenCV(_ sender: Any) {
        performSegue(withIdentifier: "goToCV", sender: self)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
       updateMarker()
    }
    
    func getBall(color : UIColor, radius: CGFloat = 0.01) -> SCNNode {
        
        //let bw : CGFloat = 0.01
        let boxGeometry = SCNSphere(radius:radius)
        let boxNode = SCNNode(geometry: boxGeometry)
        
        //boxNode.worldPosition = initialPoint!
        boxGeometry.firstMaterial?.diffuse.contents = color
        boxGeometry.firstMaterial?.lightingModel = .constant
        
        return boxNode
        
    }
    
    private func updateMarker() {
        
        guard let frame = self.sceneView.session.currentFrame else { return }
        
        let pixelBuffer = frame.capturedImage
        
        let intrinsics = frame.camera.intrinsics
        
        guard let camera = self.sceneView.pointOfView else { return }

        let markerLengthMM : Float64 = 3.5
        
        let markerLength : Float64 = markerLengthMM / 1000.0
        
        let result = OpenCVWrapper.findPose(pixelBuffer, withIntrinsics: intrinsics, andMarkerSize: markerLength)
        
        if result.found {
            
            let dist = -result.tvec.z
            
            if lastDistance == nil {
                lastDistance = dist
            }
            
            lastDistance - (lastDistance - dist) * 0.1
            
            let posInCam = SCNVector3(-result.tvec.y, -result.tvec.x, lastDistance )
            
            let camMat = SCNMatrix4ToGLKMatrix4(camera.worldTransform)
            
            let worldPos = SCNVector3FromGLKVector3(GLKMatrix4MultiplyVector3WithTranslation(camMat, SCNVector3ToGLKVector3(posInCam)))
            
            let rotMat = result.rotMat
            
            var xDir = rotMat.xAxis
            xDir = SCNVector3( xDir.y, xDir.x , xDir.z )
            let xWorldDir = SCNVector3FromGLKVector3(GLKMatrix4MultiplyVector3(camMat, SCNVector3ToGLKVector3(xDir)))
            let worldRot = SCNMatrix4Mult(rotMat, camera.worldTransform)
            
            ballNode.position = worldPos
            
            if lastPos == nil {
                lastPos = worldPos
            }
            
            lastFoundPos = worldPos
            lastFoundRotMat = worldRot
            
            lastFoundxDir = xWorldDir
            
            
        }
        
    }

}

