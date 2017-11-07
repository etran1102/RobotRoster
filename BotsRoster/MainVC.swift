//
//  MainVC.swift
//  BotsRoster
//
//  Created by Erick Tran on 10/18/17.
//  Copyright © 2017 Erick Tran. All rights reserved.
//

/*
 
Class Overview
==============
    
This class is inteded to allow user to view the robots through a table view. Each cell contain image, name, code name, speed, strength, and agility of the robot. This class can also sort all robot based on their name, speed, strength, or agility with ascending order.

Typical use
===========

 View some data for each robot.
 Sort robot using their name, speed, strength, or agility.
 Create new robot.

Functions:
==========

 viewDidLoad()
 backPressed()
 numberOfSections()
 tableView(numberOfRows)
 tableView(cellForRowAt)
 configureCell()
 tableView(didSelectRowAt)
 retrieveData()
 segmentChange()
 addBtnPressed()
 generateNewRobot
 controllerWillChangeContent()
 controllerDidChangeContent()
 controller(didChangeAn Object)
 prepare(forSegue)
 createAlert()

*/

import UIKit
import CoreData

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    // Declare UI variables
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    
    // Declare all varibales
    var controller: NSFetchedResultsController<Robot>!
    var mainTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableview initiate delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        //set title for the VC
        titleLbl.text = mainTitle
        
        //read data from memory
        retrieveData()
  
    }

    // Define number of section for table view. 
    // set number of section on tableview either the amount of sections from memory or to if core data is empty.
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = controller.sections {
            return sections.count
        }
        return 0
    }
    
    // Define number of row for table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = controller.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    // Configure each cell for the table view using the data from core data.
    // Using reusable cell to protect memory and faster loading.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BotCell", for: indexPath) as! BotCell
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)        
        return cell
    }
    
    // Call configure function from the BotCell class to create 1 cell for table view at a particular index path.
    func configureCell(cell: BotCell, indexPath: NSIndexPath) {
        let robot = controller.object(at: indexPath as IndexPath)
        cell.configureCell(robot: robot)
    }
    
    // Actions when user select a cell on table view.
    // perform segue to a more detail view to show all elements of the particular robot that in table view.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let objs = controller.fetchedObjects , objs.count > 0 {
            let robot = objs[indexPath.row]
            performSegue(withIdentifier: "toDetailVC", sender: robot)
        }
    }
    
    // Back button is use to go back to select menu and choose between a starter list or a substitute list of robot that participate.
    // Using dismiss instead of perform a segue is a safer way to nagivate and to reduce the use of memory.
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Retrieve data from core data
    // Retrieve data with either a starters list or a substitutes list
    // Sort data by name, speed, strength, or agility.
    func retrieveData() {
        
        // Create request with filter for either starters or substitutes
        let filter = mainTitle
        let predicate = NSPredicate(format: "list = %@", filter!)
        let request: NSFetchRequest<Robot> = Robot.fetchRequest()
        request.predicate = predicate
        
        // Sort data depend on name, speed, strength, or agility. Each with ascending order.
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        let speedSort = NSSortDescriptor(key: "speed", ascending: true)
        let strengthSort = NSSortDescriptor(key: "strength", ascending: true)
        let agilitySort = NSSortDescriptor(key: "agility", ascending: true)
        
        // Using segment control to modify the fetch request for correct data.
        if segment.selectedSegmentIndex == 0 {
            request.sortDescriptors = [nameSort]
        } else if segment.selectedSegmentIndex == 1 {
            request.sortDescriptors = [speedSort]
        } else if segment.selectedSegmentIndex == 2 {
            request.sortDescriptors = [strengthSort]
        } else if segment.selectedSegmentIndex == 3 {
            request.sortDescriptors = [agilitySort]
        }
        
        // Define the controller for fetch result objects.
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        self.controller = controller
        
        // Use do try catch to fetch data incase something went wrong and it protect the app from crashing.
        do {
            try controller.performFetch()
        } catch {
            let error = error as NSError
            print("\(error)")
        }
    }
    
    // Segment changing the order of the table view and also changing the order of data that got retrieve.
    @IBAction func segmentChange(_sender: Any) {
        retrieveData()
        tableView.reloadData()
    }
    
    // Action for add button.
    // This fuction will retrieve data from core data for both starts and substitudes to pass to generateNewRobot().
    // This function also check for limit of 10 starters and 5 substitudes.
    @IBAction func addBtnPressed(_ sender: Any) {
        
        // Declare variables
        var names = [String]()
        var tempNames = [String]()
        var codeNames = [String]()
        var salaries = [Int]()

        // Creating a new fetch request from core data.
        let totalRequest: NSFetchRequest<Robot> = Robot.fetchRequest()

        // Sort result by name and declare new controller for the result
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        totalRequest.sortDescriptors = [nameSort]
        let newController = NSFetchedResultsController(fetchRequest: totalRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Use do try catch on performFetch() to make sure things get handle in case of error.
        do {
            try newController.performFetch()
            
        } catch {
            let error = error as NSError
            print(error)
        }
        
        // Create a new arrays that contain names, codeNames, and salaries for all robot received from core data.
        for robot in newController.fetchedObjects! {
            names.append(robot.name!)
            codeNames.append(robot.codeName!)
            salaries.append(Int(robot.salary))
        }
        
        // Create a list of name of current list which is either starters or substitutes.
        for robot in controller.fetchedObjects! {
            tempNames.append(robot.name!)
        }
        
        // Print out the list of salaries on the console for easy checking.
        print(salaries)
        
        // Check if it is the starters list
        if mainTitle == "Starters" {
            
            // Check if the list have reach the limit of starters
            if tempNames.count < 10 {
                // Call generateNewRobot() if the list haven't reach limit.
                generateNewRobot(names: names, codeNames: codeNames, salaries: salaries)
            } else {
                // Create alert and let user if the limit have reached.
                createAlert(title: "Uh-oh", message: "You can only have 10 Starters")
            }
            
        } else {
            
            // Check if the lsit have reach the limit of substitutes.
            if tempNames.count < 5 {
                // Call generateNewRobot() if the list haven't reach limit.
                generateNewRobot(names: names, codeNames: codeNames, salaries: salaries)
            } else {
                // Create alert and let user if the limit have reached.
                createAlert(title: "Uh-oh", message: "You can only have 5 Substitutes")
            }
        }
        
    }
    
    // Generate a new robot using the input taken addBtnPressed()
    // Make sure that the data generate is fit into the requirements.
    func generateNewRobot(names: [String], codeNames: [String], salaries: [Int]) {
        
        // Declare variables.
        var name: String!
        var codeName: String!
        var codeNameLetter: String!
        var codeNameNumber: Int!
        var speed: Int!
        var strength: Int!
        var agility: Int!
        var totalAttribute = 0
        var salary: Int!
        var totalSalaries = 0
        var index: Int!
        
        // Create a list of name that possible for the robot.
        // Having 25 name for 15 robots create a more variaties in name selecting.
        let nameArray = ["Optimus Prime","Sentinel Prime","Bumblebee","Bluestreak","Hound","Cliffjumper","Ironhide","Prowl","Rachet","Sunstreaker","Hoist","Hot Rod","Brawn","Kup","Gears","Cosmos","Warpath","Wheelie","Grimlock","Slag","Sludge","Snarl","Swoop"]
        
        // Generate the speed, strength, and agility. 
        // Make sure that the sum of all three doesn't exceed 100.
        repeat {
            speed = Int(arc4random_uniform(70)) + 10
            strength = Int(arc4random_uniform(70)) + 10
            agility = Int(arc4random_uniform(70)) + 10
            totalAttribute = speed + strength + agility
        } while totalAttribute > 100
        
        // Generate a random name from the name list above.
        // Make sure that the name doesn't match any name that alaready exist.
        repeat {
            let random = Int(arc4random_uniform(UInt32(nameArray.count)))
            name = nameArray[random]
        } while names.contains(name)
        
        // Generate the code name for the robot.
        // Make sure that code name is not matching any code names that already exist.
        repeat {
            
            // Declare all upper case letters.
            let letters : NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            let len = UInt32(letters.length)
            
            var randomString = ""
            
            // Select 3 random letters.
            for _ in 0 ..< 3 {
                let rand = arc4random_uniform(len)
                var nextChar = letters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
            codeNameLetter = randomString
            
            // Select a 4 digit random number.
            codeNameNumber = Int(arc4random_uniform(8999) + 1000 )
            
            // Combine letters and number to create a unique name.
            codeName = "\(codeNameLetter!)\(codeNameNumber!)"

        } while codeNames.contains(codeName)
        
        // Checking salary array for any exist element. 
        // If not, then generate the first number for salary.
        // Index prevent for loop go into ifinite loop if the sum of salaries is too high and can't generate a new one that fit the requirements.
        if salaries.count > 0 {
            
            // Reset index
            index = 0

            // Generate a random salary and make sure it it the requirement.
            // While loop will quit after trying 100 combos.
            repeat {
                salary = Int(arc4random_uniform(12) + 5)
                for i in 0 ... (salaries.count - 1) {
                    totalSalaries = totalSalaries + salaries[i]
                }
                totalSalaries = totalSalaries + salary
                index = index + 1
            } while (totalSalaries > 175 && index <= 100)
            
        } else {
            // Generate first salary.
            index = 0
            salary = Int(arc4random_uniform(12) + 5)
        }
        
        // Check index to see if it couldn't find a compatible number for the salary.
        // Create a new robot if if the salary is good. 
        // Send alert to user if the salaries are too high and need to delete some robot.
        if index <= 100 {
            
            // Declare new robot.
            let newRobot = NSEntityDescription.insertNewObject(forEntityName: "Robot", into: context)
        
            // Set generated value for the new robot.
            newRobot.setValue(name, forKey: "name")
            newRobot.setValue(codeName, forKey: "codeName")
            newRobot.setValue(Int32(speed), forKey: "speed")
            newRobot.setValue(Int32(strength), forKey: "strength")
            newRobot.setValue(Int32(agility), forKey: "agility")
            newRobot.setValue(Int32(salary), forKey: "salary")
            newRobot.setValue(mainTitle, forKey: "list")
            
            // Save new robot to core data
            appDelegate.saveContext()
        
            // Reload table view with new robot.
            tableView.reloadData()
            
            // Make alert to let user know the name of the robot just successfully saved to core data.
            createAlert(title: "Awesome", message: "A new robot bot named \(name!) have been created.")
        
        } else {
            
            // Alert let user know that the total salary are too high and need to delete some high salary robot.
            createAlert(title: "Uh-Oh", message: "The total of salary are too high. Please adjust the salary accordingly!")
        }
    }
    
    // Content of table view will change.
    // Prepare the update for table view.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    // Content of table view alaready changed. 
    // End the update for table view.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // Controller if the object is change.
    // This will allow user to add pictures for each individual robot and then save it.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        // Switch statement to handle what kind of changed happend to the object.
        switch(type) {
        
        // Handle when insert an object.
        case.insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            } else {
                print("New index path is invalid in insert")
            }
            break
            
        // Handle when delete an object.
        case.delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                print("New index path is invalid in delete")
            }
            break
        
        // Handle when the object get uupdate.
        case.update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! BotCell
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            } else {
                print("New index path is invalid in update")
            }
            break
            
        // Handle when the object have moved.
        case.move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                print("Index path is invalid in move")
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            } else {
                print("New indexpath is invalid in move")
            }
            break
        }
    }
    
    // Prepare data to perform a segue. 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            // Make sure that with toDetailVC identifier we will arrive at DetailVC.
            if let destination = segue.destination as? DetailVC {
                if let robot = sender as? Robot {
                    destination.robotToEdit = robot
                } else {
                    print("Object passing through is not type Robot")
                }
            } else {
                print("Destination is not DetailVC")
            }
        }
    }
    
    // Create aler with single action of dismiss to notify user. 
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    
    }

}

