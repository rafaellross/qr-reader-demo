//
//  ViewController.swift
//  QRReaderDemo
//
//  Created by Simon Ng on 23/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var viewCam: UIView!
    
    //Labels
    
    @IBOutlet weak var lbPenoNumber: UILabel!
    
    @IBOutlet weak var lbProject: UILabel!
   
    @IBOutlet weak var lbManufacturer: UILabel!
    
    @IBAction func btnClear(_ sender: UIButton) {
        lbPenoNumber.text = ""
        lbProject.text = ""
        lbManufacturer.text = ""
        
    }
    
    var penoId: String = ""
    
    
    @IBAction func btnContinue(_ sender: UIButton) {
      performSegue(withIdentifier: "SegueEdit", sender: self)
    
    }
    
    @IBOutlet weak var btnContinue: UIButton!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC : EditController = segue.destination as! EditController
        destVC.penoId = self.penoId
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //btnContinue.isEnabled = false
        
        view.backgroundColor = UIColor.white
        viewCam.backgroundColor = UIColor.black
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewCam.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewCam.layer.addSublayer(previewLayer)
        
        
        
        

        captureSession.startRunning()
        
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            //messageLabel.text = stringValue
            
            struct Penetration: Codable {
                var id: Int
                var project: String
                var fire_number: String
                var fire_seal_ref: String
                var fire_resist_level: String
                var manufacturer: String
                
            }
            
            let jsonData = stringValue.data(using: .utf8)!
            let decoder = JSONDecoder()
            let penetration = try! decoder.decode(Penetration.self, from: jsonData)
            
            //Set Text to fields
            lbPenoNumber.text = penetration.fire_number
            lbProject.text = penetration.project
            lbManufacturer.text = penetration.manufacturer
            self.penoId = String(penetration.id)
            btnContinue.isEnabled = true
            captureSession.startRunning()
            
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        print(code)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}

