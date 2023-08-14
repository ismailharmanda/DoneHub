//
//  ViewController.swift
//  Todoey
//
//  Created by ismail harmanda on 09/07/2023.
//  Copyright © 2023 ismail harmanda. All rights reserved.
//

import UIKit

@available(iOS 16.0, *)
class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "Items.plist")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        let newItem1 = Item(title:"Find Mike")
//        let newItem2 = Item(title:"Buy Eggos")
//        let newItem3 = Item(title:"Destroy Demogorgon")
//        
//        itemArray += [newItem1,newItem2,newItem3]
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
        
        selectedItem.toggle()
        
        saveItems()
        
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
        
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }
        
        self.tableView.reloadData()
        
    }
    
    func loadItems(){
        
        
        if let safeItems = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            do{
                itemArray = try decoder.decode( [Item].self, from: safeItems)
            }catch{
                print(error)
            }
        }
        
    }
    
}
