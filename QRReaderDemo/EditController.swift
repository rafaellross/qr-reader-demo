//
//  EditController.swift
//  QRReaderDemo
//
//  Created by Vince Molluso on 30/7/18.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class EditController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCaptureMetadataOutputObjectsDelegate {

    var penoId :String = ""
    
    @IBOutlet weak var lbPenoId: UILabel!
    
    //Labels
    
    @IBOutlet weak var lbRef: UILabel!
    
    @IBOutlet weak var lbDrawing: UILabel!
    
    @IBOutlet weak var lbInstall_dt: UILabel!
    @IBOutlet weak var lbResistance: UILabel!
    @IBOutlet weak var lbInstalled_By: UILabel!

    @IBOutlet weak var lbManufacturer: UILabel!
    
    //Photo
    
    @IBOutlet weak var viewPhoto: UIView!

    @IBOutlet weak var imageTake: UIImageView!   

    var imagePicker: UIImagePickerController!

 
    let captureSession = AVCaptureSession()   // inicio de sessão
    let capturePhotoOutput = AVCapturePhotoOutput()   // objeto de video
    var previewLayer: AVCaptureVideoPreviewLayer? // previa da capturado video
    var captureDevice: AVCaptureDevice? // device da captura de video
    var cameraflag = true // flag de controle para virar a camera
    
    
    
    
    
    @IBAction func btnTakePicture(_ sender: UIButton) {
	imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
    }


    //MARK: - Done image capture here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
         imagePicker.dismiss(animated: true, completion: nil)
         imageTake.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    

    
    @IBAction func btnClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDevice()
        
        //get from api
        let urlString = "http://192.168.1.119:8000/api/penetration/" + penoId
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            //Implement JSON decoding and parsing
            do {
                struct Penetration: Codable {
                
                    var id: Int
                    var job_id: Int
                    var fire_seal_ref: String
                    var fire_resist_level: String
                    var install_dt: String
                    var install_by: String
                    var manufacturer: String
                    var created_at: String
                    var updated_at: String
                    var fire_photo: String? = nil	
               
                    var fire_number: Int
                    var drawing: String

                    
                }
                
                do {
                    
                    let penetration = try JSONDecoder().decode(Penetration.self, from: data)
                    //Get back to the main queue
                    DispatchQueue.main.async {
                        //print(articlesData)
                        self.lbRef.text = String(penetration.fire_number)
                        
                        self.lbResistance.text = penetration.fire_resist_level
                        self.lbDrawing.text = penetration.drawing
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        self.lbInstall_dt.text = penetration.install_dt
                        self.lbInstalled_By.text = penetration.install_by
                        self.lbManufacturer.text = penetration.manufacturer
                        
                    }
                    
                } catch {
                    
                    let ac = UIAlertController(title: "Penetration not found!", message: "This penetration is not available on database!", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    //self.dismiss(animated: true, completion: nil)
                    self.present(ac, animated: true)
                    

                }
                
                
                
               
              
                
             
                
            } catch let jsonError {
                print(jsonError)
            }
            
            
            }.resume()        // Do any additional setup after loading the view.
    }
    
    func setDevice(){
        
        self.captureSession.sessionPreset = AVCaptureSession.Preset.high // ajuste de settings da captura de video
        // procura por algum device
        captureDevice =  AVCaptureDevice.default(for: .video) else {
            print("Não encontrou a camera")
            return
        }
        
        
        beginSession()
        
        
        
    }
    
    func beginSession() {
        
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
            
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
           
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = viewPhoto.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        viewPhoto.layer.addSublayer(previewLayer!)
        
       
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
