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
    
    @IBOutlet weak var xValue: UITextField!
    @IBOutlet weak var yValue: UITextField!
    @IBOutlet weak var zValue: UITextField!
    
    var showPlane: Bool = false
    
    let sample = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    
//    let sample = "Oxymoron Heinous Paradigm Paradox Zephyr Milieu"
    
    var currentDef: String? = nil
    var pageText : SCNNode! = nil
    var myPage : BookPage! = nil
    var marker: SCNNode! = nil
    private var originNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.session.delegate = self
     //   sceneView.debugOptions = [ARSCNDebugOptions.showBoundingBoxes]
        
        self.useArKit()
        self.createSphere()
        
        myPage = BookPage(width: MARKER_SIZE_IN_METERS, height: MARKER_SIZE_IN_METERS, text: sample)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let hitResults = sceneView.hitTest(touch.location(in: sceneView), options: [:])
            if !hitResults.isEmpty {
                guard let hitResult = hitResults.first else {
                    return
                }
               // vibrateWithHaptic()
                let node = myPage.findClosest(referencePoint: hitResult.worldCoordinates)
                DispatchQueue.main.async {
                    self.marker.isHidden = false
                    self.marker.position = hitResult.worldCoordinates
                }
                showDefinition(myNode: node)
            }
    }
    
    func showDefinition(myNode: SCNNode) {
        if let myText = myNode.geometry as? SCNText {
            print(myText.string)
        }
        
    }
    
    func createSphere() {
        let sphereGeometry = SCNSphere(radius: 0.001)
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        self.marker = sphereNode
        self.marker.isHidden = true
        sceneView.scene.rootNode.addChildNode(marker)
    }
    
    func vibrateWithHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        
        generator.impactOccurred()
    }

    
    private func useArKit() {
      //  sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
        let configuration = ARWorldTrackingConfiguration()
        self.sceneView.session.run(configuration)
    }
    
    @IBAction func goTOOpenCV(_ sender: Any) {
        performSegue(withIdentifier: "goToCV", sender: self)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        localizeMarker()
    }

    private func localizeMarker() {
        
        guard let frame = self.sceneView.session.currentFrame else { return }
        
        let pixelBuffer = frame.capturedImage
        
        let intrinsics = frame.camera.intrinsics
        
        let transMatrix = OpenCVWrapper.transformMatrix(from: pixelBuffer, withIntrinsics: intrinsics, andMarkerSize: Float64(MARKER_SIZE_IN_METERS));
        
        if (SCNMatrix4IsIdentity(transMatrix)) {
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
         //   originNode.addChildNode(myPage.getPlane())
            //originNode.addChildNode(myPage.getText())
            originNode.addChildNode(myPage)
            myPage.highlight()
            showPlane = true
        }
    }
    
    private var ballHighlight: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            // .fadeOut(duration: 0.5),
            //   .removeFromParentNode()
            ])
    }

}

