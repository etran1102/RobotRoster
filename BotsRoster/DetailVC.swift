//
//  DetailVC.swift
//  BotsRoster
//
//  Created by Erick Tran on 10/19/17.
//  Copyright © 2017 Erick Tran. All rights reserved.
//

/*
 
 Class Overview
 ==============
 
 This class is intended to allow user to view robot data in detail and also edit the image for an individual robot.
 
 Typical use
 ===========

 View detail data for each robot.
 Add/Change the robot image.
 Save/Delete robot.
 
 Functions:
 ==========
 
 viewDidLoad()
 backPressed()
 savePressed()
 deletePressed()
 imagePickerController()
 createAlert()
 
 */

import UIKit
import CoreData

class DetailVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    // Declare UI varibales.
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var codeNameLbl: UILabel!
    @IBOutlet weak var listLbl: UILabel!
    @IBOutlet weak var speedLbl: UILabel!
    @IBOutlet weak var strengthLbl: UILabel!
    @IBOutlet weak var agilityLbl: UILabel!
    @IBOutlet weak var salaryLbl: UILabel!
    
    // Declare variables.
    var robotToEdit: Robot?
    var imagePicker: UIImagePickerController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial image picker.
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // Display data received to screen.
        if robotToEdit != nil {
            if robotToEdit?.toImage?.image == nil {
                thumbnail.image = UIImage(named: "imagePick")
            } else {
                thumbnail.image = robotToEdit?.toImage?.image as? UIImage
            }
            nameLbl.text = robotToEdit?.name
            codeNameLbl.text = robotToEdit?.codeName
            listLbl.text = robotToEdit?.list
            speedLbl.text = "\((robotToEdit?.speed)!)"
            strengthLbl.text = "\((robotToEdit?.strength)!)"
            agilityLbl.text = "\((robotToEdit?.agility)!)"
            salaryLbl.text = "\((robotToEdit?.salary)!)"
        }
    }

    // Dismiss VC when back button is press.
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Let user pick the image they want to use for the robot.
    // Present image picker and access to photo libarary.
    @IBAction func thumbnailImagePressed(_ sender: Any) {
        present(imagePicker, animated: true, completion:  nil)
    }
    
    // Action for save button.
    @IBAction func savePressed(_ sender: Any) {
        
        // Create variables.
        var robot: Robot!
        let picture = Image(context: context)
        
        // Set image that user pick to image content object.
        picture.image = thumbnail.image
        
        // Set robot to be the robot that passed through table view.
        if robotToEdit == nil {
            robot = Robot(context: context)
        } else {
            robot = robotToEdit
        }
        
        // Add image to robot.
        robot.toImage = picture

        // Save image to core data for the specific robot.
        appDelegate.saveContext()

        // Dismiss the DetailVC
        self.dismiss(animated: true, completion: nil)
    }
    
    // Action for delete button.
    @IBAction func deletePressed(_ sender: Any) {
        
        // Use async to delete the object in the background.
        DispatchQueue.global().async {
            if self.robotToEdit != nil {
                context.delete(self.robotToEdit!)
                appDelegate.saveContext()
            }
        }
        
        // Dismiss DetailVC
        self.dismiss(animated: true, completion: nil)
    }
    
    // Allow user to pick the image for the particular robot that got selected.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            thumbnail.image = image
        } else {
            print("Something went wrong!")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // Create alert to notify user.
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
