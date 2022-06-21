//
//  ViewController.swift
//  Film Book
//
//  Created by Furkan Ceylan on 20.06.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    let detailsVC = DetailsViewController()
    
    var selectDataId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        navigationItem.title = "Films List"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData() //We called the data when the app was first opened.
    }

    @objc func addButtonClicked(){
        selectDataId = nil
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    // TABLEVİEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectDataId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Film")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            do{
                let results = try context?.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    if result.value(forKey: "id") as? UUID == idArray[indexPath.row]{
                        context?.delete(result)
                        nameArray.remove(at: indexPath.row)
                        idArray.remove(at: indexPath.row)
                        tableView.reloadData() 
                        do{
                            try context?.save()
                        }catch{
                            
                        }
                    }
                }
            }catch{
                
            }
        }
    }
    // TABLEVİEW
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC"{
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.choseDataId = selectDataId
        }
        
    }
    
    // Get Data and cleaning arrays
    @objc func getData(){
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Film")
        
        do{
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject]{
                if let name = result.value(forKey: "name") as? String{
                    self.nameArray.append(name)
                }
                
                if let id = result.value(forKey: "id") as? UUID{
                    self.idArray.append(id)
                }
                
                tableView.reloadData()
            }
        }catch{
            detailsVC.addAlertMessage(title: "Error", message: "Data transfer failed.", okButon: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    
    

}

