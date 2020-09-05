//
//  SecondViewController.swift
//  AstronomyPic
//
//  Created by Aman Benbi on 23/08/2020.
//  Copyright © 2020 Aman Benbi. All rights reserved.
//

import UIKit
import MessageUI
import CoreLocation
import Photos

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var emailOfObserver: UITextField!
    @IBOutlet weak var extraNotes: UITextView!
        
    // Variables to be able to share across functions.
    
    var locData = ""
    var Clloc = CLLocation.init()
    
    func closeKeyboard() {
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RemoveKeyboard))
        
        view.addGestureRecognizer(Tap)
    }
    
    @objc func RemoveKeyboard() {
        view.endEditing(true)
    }
    
    let locationM = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.closeKeyboard()
        // Do any additional setup after loading the view.
        locationM.requestAlwaysAuthorization()
        locationM.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled()  {
            locationM.delegate = self
            locationM.desiredAccuracy = kCLLocationAccuracyBest
            locationM.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location for camera.
    }
    

    // Options when uploadButton is pressed.
    
    @IBAction func takeChoosePhoto(_ sender: Any) {
        
        let imagePickerControl = UIImagePickerController()
        imagePickerControl.delegate = self
        
        let actionPage = UIAlertController(title: "Photos", message: "Choose a Method", preferredStyle: .actionSheet)
        
        actionPage.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerControl.sourceType  = .camera
                
                self.present(imagePickerControl, animated: true, completion: nil)
            }
            else {
                print("Camera is not working...")
            }
        }))
        
        actionPage.addAction(UIAlertAction(title: "Photo Gallery", style: .default, handler: { (action:UIAlertAction) in
            imagePickerControl.sourceType = .photoLibrary
            self.present(imagePickerControl, animated: true, completion: nil)
        }))
        
        actionPage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionPage, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let photo = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = photo
        picker.dismiss(animated: true, completion: nil)
        
        // IF block for the camera gallery option to find location of asset.
        
        if let URL = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerReferenceURL")] as? URL {
         let opts = PHFetchOptions()

         opts.fetchLimit = 1

         let assets = PHAsset.fetchAssets(withALAssetURLs: [URL], options: opts)

         for assetIndex in 0..<assets.count

         {
         let asset = assets[assetIndex]

         let location = String(describing: asset.location)

//         let log = String(describing: asset.location?.coordinate.longitude)
//         let lat = String(describing: asset.location?.coordinate.latitude)
//         let timeTaken = (asset.creationDate?.description)!

         print("Location: \(location)")
            locData = location

         }

        }
        
            // Else block for the camera option to find current location and time details.
            
        else {
         
            Clloc = locationM.location as! CLLocation
            
            print(String(describing: Clloc))
            
            locData = String(describing: Clloc)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Reset button reloads view
    
    @IBAction func resetButton(_ sender: Any) {
        self.loadView()
        self.viewDidLoad()
    }

    // Send email button validates userName and EmailOfObserver then sends email if device is able to.
    
    @IBAction func sendEmail(_ sender: Any) {
        let uName = userName.text ?? ""
        let emailOB = emailOfObserver.text ?? ""
        if  uName == "" || emailOB == "" {
            let usernameError = UIAlertController(title: "Missing Details Required", message: "You MUST enter the 'Name of Observer' and 'Email of Observer'.", preferredStyle: .alert)
            let close = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            usernameError.addAction(close)
            self.present(usernameError, animated: true, completion: nil)
        } else {
        let composeM = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.present(composeM, animated: true, completion: nil)
        } else {
            showError()
        }
        }
    }
    
    // This function is to compose the email with correct details.
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(["aman@abenbi.com"])
        mailComposeVC.setCcRecipients([emailOfObserver.text!])
        mailComposeVC.setSubject("New Sighting - Evidence Attached (From Public Citizen)")
        
        mailComposeVC.setMessageBody("<h1>Details of Sighting:</h1><b><h4>Name of Observer:</h4></b> " + userName.text! + "<br> <br> <b><h4>Email Address of Observer:</h4></b> " + emailOfObserver.text! + "<br><br> <h4><b>Extra Notes:</b></h4> " + extraNotes
            .text! + "<br> <br> <b><h4>Location and Date Time Details :</h4></b> " + locData + "<br> <br> <b><h4>Image:</h4></b> ", isHTML: true)
        
        let imagePickerControl = UIImagePickerController()
        imagePickerControl.delegate = self
        
        
        // Adds image as an attachment else showinputError Function is implemented.
        
        if let image = imageView.image {
            let data = image.jpegData(compressionQuality: 1.0)
            mailComposeVC.addAttachmentData(data!, mimeType: "image/jpg", fileName: "image.jpg")
        } else {
            showInputError()
        }
        return mailComposeVC
    }
    
    // Function to check whether user is able to send email from the device.
    
    func showError() {
        let mailError = UIAlertController(title: "Unable to Send Email", message: "Your device is unable to send the email", preferredStyle: .alert)
        let close = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        mailError.addAction(close)
        self.present(mailError, animated: true, completion: nil)
    }
    
    // Function to ensure a photograph has been attached
    
    func showInputError() {
        let mailError = UIAlertController(title: "Add an Image", message: "You must upload a photograph in order to send an email to NASA!", preferredStyle: .alert)
        let close = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        mailError.addAction(close)
        self.present(mailError, animated: true, completion: nil)
    }
        
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

