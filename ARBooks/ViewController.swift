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
    
    var showPlane: Bool = false

    var myPage : BookPage! = nil
    var planeNode : SCNNode! = nil
    private var originNode = SCNNode()

    var displayLink: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.session.delegate = self
        
        self.useArKit()
        
       myPage = BookPage(width: MARKER_SIZE_IN_METERS, height: MARKER_SIZE_IN_METERS)
        

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
        if !(showPlane)
        {
            originNode.addChildNode(myPage)
            myPage.highlight()
            showPlane = true
        }
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

