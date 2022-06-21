//
//  DetailsViewController.swift
//  Film Book
//
//  Created by Furkan Ceylan on 20.06.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var directorTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    var choseDataId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(systemName: "square.and.arrow.up")
        
        view.addGestureRecognizer(gestureRecegnizer(action: #selector(keyboardClosed)))
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(gestureRecegnizer(action: #selector(selectImg)))
        
        if choseDataId != nil{
            saveButton.isHidden = true
            nameTextField.isEnabled = false
            directorTextField.isEnabled = false
            yearTextField.isEnabled = false
            imageView.isUserInteractionEnabled = false
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Film")
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", (choseDataId?.uuidString)!)
            
            do{
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String{
                        nameTextField.text = name
                    }
                    
                    if let director = result.value(forKey: "director") as? String{
                        directorTextField.text = director
                    }
                    
                    if let year = result.value(forKey: "year") as? Int{
                        yearTextField.text = String(year)
                    }
                    
                    if let image = result.value(forKey: "img") as? Data{
                        imageView.image = UIImage(data: image)
                    }
                }
            }catch{
                print("Error")
            }
            
        }else{
            //
        }
    }
    
    // For Multiple gestureRecognizer Use
    @objc func gestureRecegnizer(action:Selector) -> UITapGestureRecognizer{
        return UITapGestureRecognizer(target: self, action: action)
    }
    
    // Keyboard Closed
    @objc func keyboardClosed(){
        view.endEditing(true)
    }
    
    // Select Image on PhotoLibrary
    @objc func selectImg(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    //Closed PhotoLibrary
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    // CoreData Save
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let film = NSEntityDescription.insertNewObject(forEntityName: "Film", into: context)
        
        film.setValue(nameTextField.text, forKey: "name")
        film.setValue(directorTextField.text, forKey: "director")
        
        if let year = Int(yearTextField.text!) {
            film.setValue(year, forKey: "year")
        }
        
        let dataImg = imageView.image?.jpegData(compressionQuality: 0.5)
        film.setValue(dataImg, forKey: "img")
        
        film.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            addAlertMessage(title: "Successful", message: "Registration successful.",okButon: UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: { _ in
                NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
                self.navigationController?.popViewController(animated: true)
            }))
        } catch {
            addAlertMessage(title: "Error", message: "Registration could not be completed.",okButon: nil)
        }
    }
    
    // Alert Mesagge
    @objc func addAlertMessage(title:String,message:String,okButon:UIAlertAction?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(okButon ?? UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
