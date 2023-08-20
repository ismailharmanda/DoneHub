//
//  ViewController.swift
//  Todoey
//
//  Created by ismail harmanda on 09/07/2023.
//  Copyright © 2023 ismail harmanda. All rights reserved.
//

import UIKit
import CoreData

@available(iOS 16.0, *)
class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        
    }
    
    //MARK:  TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let selectedItem = itemArray[indexPath.row]
        
        cell.textLabel?.text = selectedItem.title
        
        cell.accessoryType = selectedItem.isDone ? .checkmark : .none
        
        
        
        return cell
    }
    
    //MARK:  TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = itemArray[indexPath.row]
        
        selectedItem.isDone = !selectedItem.isDone
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedItem = itemArray[indexPath.row]
            context.delete(selectedItem)
            itemArray.remove(at: indexPath.row)
            saveItems()
        }
    }
    
    
    
    //MARK:  Add New Items
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert  = UIAlertController(title: "Add New DoneHub", message: "", preferredStyle:.alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default){
            (action) in
            // What will happen once the user clicks the Add Item button on our UIAlert
            if let safeText = textField.text{
                
                let newItem = Item(context: self.context)
                
                newItem.title = safeText
                
                self.itemArray.append(newItem)
                
                self.saveItems()
            }
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
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
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()){
        do{
            itemArray =  try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        
        
    }
    
    
    
    
    
}

//MARK:  Search bar methods

@available(iOS 16.0, *)
extension TodoListViewController: UISearchBarDelegate{
    
    //    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //        let request = Item.fetchRequest()
    //
    //        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
    //
    //        request.predicate = predicate
    //
    //        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
    //
    //        request.sortDescriptors = [sortDescriptor]
    //
    //        do{
    //         itemArray =  try context.fetch(request)
    //        }catch{
    //            print("Error fetching data from context \(error)")
    //        }
    //
    //        self.tableView.reloadData()
    //    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (containsOnlySpacesOrEmpty(searchText)){
            loadItems()
        } else {
            
            let request = Item.fetchRequest()
            
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            
            request.predicate = predicate
            
            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            
            request.sortDescriptors = [sortDescriptor]
            
            loadItems(with: request)
        }
        
        
        
        
        self.tableView.reloadData()
        
    }
    
    func containsOnlySpacesOrEmpty(_ text: String) -> Bool {
        // Trim the input text to remove leading and trailing spaces
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if the trimmed text is either empty or contains only spaces
        return trimmedText.isEmpty
    }
    
}
