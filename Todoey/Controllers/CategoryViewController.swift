//
//  CategoryViewController.swift
//  DoneHub
//
//  Created by ismail harmanda on 21.08.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import Chameleon

@available(iOS 16.0, *)
class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
//    var categories = [Category]()
    var categories : Results<RealmCategory>?

    
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.separatorStyle = .none
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        loadCategories()

    }
    

    //MARK:  Add New categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert  = UIAlertController(title: "Add New Category", message: "", preferredStyle:.alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default){
            (action) in
            // What will happen once the user clicks the Add Item button on our UIAlert
            if let safeText = textField.text{
                
//                let newCategory = Category(context: self.context)
                let newCategory = RealmCategory()
                
                newCategory.name = safeText
                
//                self.categories.append(newCategory)
                
//                self.saveItems()
                self.save(category: newCategory)
                
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
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                var textField = UITextField()
                
                let alert  = UIAlertController(title: "Edit Category Name", message: "", preferredStyle:.alert)
                
                let addAction = UIAlertAction(title: "Edit", style: .default){
                    (action) in
                    // What will happen once the user clicks the Add Item button on our UIAlert
                    if let safeText = textField.text{
                        
                        var category = self.categories?[indexPath.row]
                
                        do{
                            try self.realm.write{
                                category?.name = safeText
                            }
                            self.tableView.reloadData()
                        } catch {
                            print("Error saving category \(error)")
                        }
                    }
                    
                    
                }
                
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                    // Handle cancellation, e.g., dismiss the alert
                    alert.dismiss(animated: true, completion: nil)
                }
                
                alert.addTextField { alertTextField in
                    alertTextField.placeholder = "Type a new name"
                    textField = alertTextField
                    textField.text = self.categories?[indexPath.row].name
                }
            
                alert.addAction(addAction)
                alert.addAction(cancelAction)
                present(alert, animated: true)
            }
        }
    }
    
//    func saveCategories(){
//
//        do {
//            try context.save()
//
//        } catch {
//            print("Error saving context \(error)")
//
//        }
//
//        self.tableView.reloadData()
//
//    }
    
    func save(category: RealmCategory){
        do{
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }
    
    func delete(category: RealmCategory){
        do{
            try realm.write{
                realm.delete(category.items)
                realm.delete(category)
            }
        } catch {
            print("Error deleting category \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
//        do{
//            categories =  try context.fetch(request)
//        }catch{
//            print("Error fetching data from context \(error)")
//        }
        

            categories = realm.objects(RealmCategory.self)
        
        
    }
    
    //MARK:  TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryItemCell", for: indexPath)

        tableView.rowHeight = 80
//        let selectedItem = categories[indexPath.row]
//
//        cell.textLabel?.text = selectedItem.name
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
//        cell.accessoryType = selectedItem.isDone ? .checkmark : .none
        
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].backgroundColor ?? "#FFF")
        cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: UIColor(hexString: categories?[indexPath.row].backgroundColor ?? "#000")!, isFlat: true)
        
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
            destinationVC.selectedCategory = categories?[indexPath.row]
        }

    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let selectedCategory = categories[indexPath.row]
//            context.delete(selectedCategory)
//            categories.remove(at: indexPath.row)
//            saveCategories()
//        }
//    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let selectedCategory = categories?[indexPath.row]{
                delete(category: selectedCategory)
            }
            
        }
    }
    
    //MARK:  Data Manipulation Methods
    

}
