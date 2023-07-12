//
//  ViewController.swift
//  Todoey
//
//  Created by ismail harmanda on 09/07/2023.
//  Copyright © 2023 ismail harmanda. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    let defaults = UserDefaults.standard
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let newItem1 = Item(title:"Find Mike")
        let newItem2 = Item(title:"Buy Eggos")
        let newItem3 = Item(title:"Destroy Demogorgon")
        
        itemArray += [newItem1,newItem2,newItem3]
        
        if let safeItemArray = defaults.data(forKey: "TodoListArray") {
            do {
                itemArray = try self.decoder.decode( [Item].self, from: safeItemArray)
            }   catch {
                print(error)
            }
        }
        
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
        
        selectedItem.toggle()
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    //MARK:  Add New Items
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert  = UIAlertController(title: "Add New DoneHub", message: "", preferredStyle:.alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default){
            (action) in
            // What will happen once the user clicks the Add Item button on our UIAlert
            if let safeText = textField.text{
                
                let newItem = Item(title:safeText)
                
                self.itemArray.append(newItem)
                
                do {
                    
                    let encodedItemArray = try self.encoder.encode(self.itemArray)
                    
                    self.defaults.set(encodedItemArray, forKey: "TodoListArray")
                    
                } catch{
                    
                    print(error)
                }
                
                self.tableView.reloadData()
            }
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    
}
