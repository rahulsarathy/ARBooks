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
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var sceneView: ARSCNView!
    
    var displayLink: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(self.displayLinkDidFire))
        self.displayLink?.preferredFramesPerSecond = self.sceneView.preferredFramesPerSecond
        
        displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)

    }
    
    @objc func displayLinkDidFire(timer: CADisplayLink) {
        // Our capturer polls the ARSCNView's snapshot for processed AR video content, and then copies the result into a CVPixelBuffer.
        // This process is not ideal, but it is the most straightforward way to capture the output of SceneKit.
        let myImage = self.sceneView.snapshot()
        
        let openCVWrapper = OpenCVWrapper()
        
        //let arImage = openCVWrapper.addAR(myImage)
       // let markedImage = openCVWrapper.findMarkers(myImage)
        
        let markedImage = openCVWrapper.findMarkers(myImage)
        
        DispatchQueue.main.async {
            self.mainImage.image = markedImage
        }
        
        
    }
    


}

