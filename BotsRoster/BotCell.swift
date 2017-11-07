//
//  BotCell.swift
//  BotsRoster
//
//  Created by Erick Tran on 10/18/17.
//  Copyright © 2017 Erick Tran. All rights reserved.
//

import UIKit
import CoreData

class BotCell: UITableViewCell {

    // Declare UI variables
    @IBOutlet weak var thumbNail: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var codeNameLbl: UILabel!
    @IBOutlet weak var speedLbl: UILabel!
    @IBOutlet weak var strengthLbl: UILabel!
    @IBOutlet weak var agilityLbl: UILabel!
    
    // Configure the cell for table view. 
    // Set all value in the vell to robot value.
    func configureCell(robot: Robot) {
        
        nameLbl.text = robot.name
        codeNameLbl.text = robot.codeName
        speedLbl.text = String(robot.speed)
        strengthLbl.text = String(robot.strength)
        agilityLbl.text = String(robot.agility)
        if robot.toImage?.image == nil {
            thumbNail.image = UIImage(named: "imagePick")
        } else {
            thumbNail.image = robot.toImage?.image as? UIImage
        }
    }
    
}
