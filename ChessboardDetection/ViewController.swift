//
//  ViewController.swift
//  ChessboardDetection
//
//  Created by Rahul Sarathy on 2/1/19.
//  Copyright © 2019 Rahul Sarathy. All rights reserved.
//

import UIKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let OpenCV = OpenCVWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    // MARK: -ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        self.OpenCV.findMarker(frame.capturedImage, withCameraIntrinsics: frame.camera.intrinsics, cameraSize: frame.camera.imageResolution)

    }

}

