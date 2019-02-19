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
    
    let sample = "Venturing into the upper steps of the bond pit was like suddenly getting shipwrecked on a deserted island, all alone and with little access to order flow. I was the Robinson Crusoe of the bond pit. This apt metaphor (the solitary islander who devises a range of strategies for survival amid scarcity, the protagonist of Daniel Defoe’s 1719 novel) runs deeper; it has become a quintessential economic parable—used most notably by the Austrian School economists, who focused so much on the actions of the individual in exchanging one state of affairs for another (what they called “autistic exchange”)."
    
    
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
        
        myPage = BookPage(width: 0.2159, height: 0.2794, text: sample)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let hitResults = sceneView.hitTest(touch.location(in: sceneView), options: [:])
            if !hitResults.isEmpty {
                guard let hitResult = hitResults.first else {
                    return
                }
               // vibrateWithHaptic()
               // let node = myPage.findClosest(referencePoint: hitResult.worldCoordinates)
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
            let findDef: String = myText.string as! String
            myPage.getDefinition(word: findDef)
        }
        else {
            
            return
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

