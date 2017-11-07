//
//  SelectVC.swift
//  BotsRoster
//
//  Created by Erick Tran on 10/18/17.
//  Copyright © 2017 Erick Tran. All rights reserved.
//


/*

 Class Overview
 ==============
 
 This class is inteded to allow user select the list of robot that they want to see.
 
 Typical use
 ===========
 
 Select list of robot that user wish to see.
 
 Functions:
 ==========
 viewDidLoad()
 startersBtnPressed()
 substitutesBtnPressed()
 
*/

import UIKit

class SelectVC: UIViewController {

    // Declare UI variables
    @IBOutlet weak var startersBtn: UIButton!
    @IBOutlet weak var substitudesBtn: UIButton!
    var titleToPass: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Action for starters button
    @IBAction func startersBtnPressed(_ sender: Any) {
        titleToPass = "Starters"
        performSegue(withIdentifier: "toMainVC", sender: nil)
    }

    // Action for substitutes
    
    @IBAction func substitutesBtnPressed(_ sender: Any) {
        titleToPass = "Substitutes"
        performSegue(withIdentifier: "toMainVC", sender: nil)
    }
    
    
    
    // Passing necessary variables for next VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toMainVC") {
            if let destination = segue.destination as? MainVC {
                destination.mainTitle = titleToPass
            } else {
                print("Destination is not MainVC")
            }
        }
    }
}
