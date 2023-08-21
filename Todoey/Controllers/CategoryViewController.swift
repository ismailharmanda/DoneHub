//
//  CategoryViewController.swift
//  DoneHub
//
//  Created by ismail harmanda on 21.08.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreData

@available(iOS 16.0, *)
class CategoryViewController: UITableViewController {
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadItems()
    }
    

    //MARK:  Add New categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert  = UIAlertController(title: "Add New Category", message: "", preferredStyle:.alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default){
            (action) in
            // What will happen once the user clicks the Add Item button on our UIAlert
            if let safeText = textField.text{
                
                let newItem = Category(context: self.context)
                
                newItem.name = safeText
                
                self.categories.append(newItem)
                
                self.saveItems()
            }
            
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // Handle cancellation, e.g., dismiss the alert
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
    
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func saveItems(){
        
        do {
            try context.save()
            
        } catch {
            print("Error saving context \(error)")
            
        }
        
        self.tableView.reloadData()
        
    }
    
    func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        do{
            categories =  try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        
        
    }
    
    //MARK:  TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryItemCell", for: indexPath)
        
        let selectedItem = categories[indexPath.row]
        
        cell.textLabel?.text = selectedItem.name
        
//        cell.accessoryType = selectedItem.isDone ? .checkmark : .none
        
        
        
        return cell
    }
    

    
    //MARK:  TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        let selectedItem = categories[indexPath.row]
        
    
        
        performSegue(withIdentifier: "goToItems", sender: self)
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories[indexPath.row]
        }

    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedItem = categories[indexPath.row]
            context.delete(selectedItem)
            categories.remove(at: indexPath.row)
            saveItems()
        }
    }
    
    //MARK:  Data Manipulation Methods
    

}
