//
//  ViewController.swift
//  ChessboardDetection
//
//  Created by Rahul Sarathy on 2/1/19.
//  Copyright © 2019 Rahul Sarathy. All rights reserved.
//

import UIKit
import ARKit

let MARKER_SIZE_IN_METERS : CGFloat = 0.2032;


class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var showCV: Bool = false

    var ballNode : SCNNode! = nil
    var myPage : BookPage! = nil
    var planeNode : SCNNode! = nil
    private var originNode = SCNNode()

    
    var displayLink: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.session.delegate = self
        
        self.useArKit()
        
       myPage = BookPage(width: MARKER_SIZE_IN_METERS, height: MARKER_SIZE_IN_METERS)
       // myPage.name = "myPage"
        self.planeNode = createPlane()
        
        self.ballNode = getBall(color: UIColor.green.withAlphaComponent(0.8), radius: 0.005)
        self.sceneView.scene.rootNode.addChildNode(ballNode)

    }
    
    private func useArKit() {
        sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
        let configuration = ARWorldTrackingConfiguration()
        self.sceneView.session.run(configuration)
    }
    
    @IBAction func goTOOpenCV(_ sender: Any) {
        performSegue(withIdentifier: "goToCV", sender: self)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
      // updateMarker()
        localizeMarker()
    }
    
    func getBall(color : UIColor, radius: CGFloat = 0.01) -> SCNNode {
        
        print(radius)
        
        //let bw : CGFloat = 0.01
        let boxGeometry = SCNSphere(radius:radius)
        let boxNode = SCNNode(geometry: boxGeometry)
        
        //boxNode.worldPosition = initialPoint!
        boxGeometry.firstMaterial?.diffuse.contents = color
        boxGeometry.firstMaterial?.lightingModel = .constant
        
        return boxNode
        
    }
    
    private func localizeMarker() {
        
        guard let frame = self.sceneView.session.currentFrame else { return }
        
        let pixelBuffer = frame.capturedImage
        
        let intrinsics = frame.camera.intrinsics
        
        let transMatrix = OpenCVWrapper.transformMatrix(from: pixelBuffer, withIntrinsics: intrinsics, andMarkerSize: Float64(MARKER_SIZE_IN_METERS));
        
        if (SCNMatrix4IsIdentity(transMatrix)) {
            print("no marker")
            return
        }
        
        let cameraTransform = SCNMatrix4.init(frame.camera.transform);
        //Multiply camera current position with translation matrix
        let targTransform = SCNMatrix4Mult(transMatrix, cameraTransform);
        
        originNode.setWorldTransform(targTransform)
        if !sceneView.scene.rootNode.childNodes.contains(originNode)
        {
            sceneView.scene.rootNode.addChildNode(originNode)
        }
        if !(originNode.childNodes.contains(planeNode))
        {
            originNode.addChildNode(planeNode)
            originNode.addChildNode(myPage)
        }
        //ballNode.position = targTransformlin
    }
    
    private func createPlane() -> SCNNode {
        let plane = SCNPlane(width: MARKER_SIZE_IN_METERS, height: MARKER_SIZE_IN_METERS)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        plane.materials = [material]
        let planeNode = SCNNode(geometry: plane)
        // planeNode.eulerAngles.x = .pi / 2
        return planeNode
    }

}

