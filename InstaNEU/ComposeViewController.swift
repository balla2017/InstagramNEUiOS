//
//  ComposeViewController.swift
//  InstaNEU
//
//  Created by Ashish on 4/17/18.
//  Copyright © 2018 Ashish. All rights reserved.
//

import UIKit

import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ComposeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var ref: DatabaseReference!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var txtPost: UITextView!
    @IBOutlet weak var btnSelectImage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func CancelPost(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func AddPost(_ sender: UIBarButtonItem) {
        
        // Convert Image to Data
        var data = NSData()
        data = UIImageJPEGRepresentation(imageView.image!, 0.8) as! NSData
        // Get user ID
        let uid = Auth.auth().currentUser?.uid
        // Storage Reference
        let storageRef = Storage.storage().reference()
        // Get reference to the Image
        let imgURL : String = "Images" + "/" + uid! + "/" + GetImageName()
        let imgRef = storageRef.child(imgURL)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        // Add data to storage
        imgRef.putData(data as Data, metadata: metaData) { (metaData, error) in
            
            if let error = error{
                print(error.localizedDescription)
                return
            }else{
                print("File is uploaded")
            }
        }
        
        // Now add the Post in the database
        
        let post = [
            "postText" : txtPost.text,
            "imgURL" : imgURL,
            "dateTime" : GetDateTime(),
            "likedBy": ""
        
        ] as  [String : Any]
        
        ref.child("Posts").child(uid!).childByAutoId().setValue(post)
        
        
        ref.child("Post").child(uid!).childByAutoId().setValue(txtPost.text)
        
        
        
        
        // dismiss dialog
        dismiss(animated: true, completion: nil)

        
        
    }
    
    
    func GetDateTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let strDate = String(components.month!) + "/"
            + String(components.day!) + "/"
            + String(components.year!) + "/ "
            + String(components.hour!) + ":"
            + String(components.minute!) + ":"
            + String(components.second!)
        return strDate;
    }
    
    
    
    func GetImageName() -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let strImage = "IMG_" + String(components.year!) + "_"
                              + String(components.month!) + "_"
            + String(components.day!) + "_"
            + String(components.hour!) + "_"
            + String(components.minute!) + "_"
            + String(components.second!) + ".jpg"
        return strImage;
    }
    
    
    
    @IBAction func SelectImage(_ sender: UIButton) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionsheetController: UIAlertController = UIAlertController(title: "Select Source of Image", message: "Please select source of image", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionsheetController.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            // add code for camera
            if(UIImagePickerController.isSourceTypeAvailable(.camera)){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
                
            }else{
                print("Camera not available")
            }
        }))
        
        actionsheetController.addAction(UIAlertAction(title: "Photo gallery", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            // add code for Photo gallery
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionsheetController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            // add code for camera
        }))
        
        
        actionsheetController.popoverPresentationController?.sourceView = btnSelectImage
        
        present(actionsheetController, animated: true, completion: nil)
        
        
    }
    
    // When user Cancels an image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // When user selects an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
}
