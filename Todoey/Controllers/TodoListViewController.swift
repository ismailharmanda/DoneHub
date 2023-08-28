//
//  ViewController.swift
//  Todoey
//
//  Created by ismail harmanda on 09/07/2023.
//  Copyright © 2023 ismail harmanda. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift


@available(iOS 16.0, *)
class TodoListViewController: UITableViewController, UISearchBarDelegate {
    
    let realm = try! Realm()
    
    //    var itemArray = [Item]()
    var items: Results<RealmItem>?
    
    //    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //    var selectedCategory: Category? {
    //        didSet{
    //            self.navigationItem.title = self.selectedCategory?.name
    //            loadItems()
    //        }
    //    }
    var selectedCategory: RealmCategory? {
        didSet{
            self.navigationItem.title = self.selectedCategory?.name
            loadItems()
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        loadItems()
    }
    //MARK:  TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        itemArray.count
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
       
        var darkenPercentage : CGFloat = 1.0
        if let itemCount = items?.count{
            darkenPercentage = CGFloat(indexPath.row) / CGFloat(itemCount)
        }

        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.lineBreakMode = .byWordWrapping;
//        cell.backgroundColor = UIColor(hexString: items?[indexPath.row].backgroundColor ?? "#FFF")
        cell.backgroundColor = UIColor.flatSkyBlue().darken(byPercentage: darkenPercentage)
//        cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: UIColor(hexString: items?[indexPath.row].backgroundColor ?? "#000")!, isFlat: true)
//        cell.tintColor = UIColor.init(contrastingBlackOrWhiteColorOn: UIColor(hexString: items?[indexPath.row].backgroundColor ?? "#000")!, isFlat: true)
        cell.textLabel?.textColor = UIColor.white.darken(byPercentage: (darkenPercentage)/3.0)
        cell.tintColor = UIColor.white
        
        //        let selectedItem = itemArray[indexPath.row]
        //
        //        cell.textLabel?.text = selectedItem.title
        //
        //        cell.accessoryType = selectedItem.isDone ? .checkmark : .none
        
        if let selectedItem = items?[indexPath.row]{
            cell.textLabel?.text = selectedItem.title
            cell.accessoryType = selectedItem.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK:  TableView Delegate Methods
    
    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //
    //        let selectedItem = itemArray[indexPath.row]
    //
    //        selectedItem.isDone = !selectedItem.isDone
    //
    //        saveItems()
    //
    //        tableView.deselectRow(at: indexPath, animated: true)
    //
    //    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = items?[indexPath.row]{
            
            do
            {
                try realm.write {
                item.done = !item.done
            }
            }catch{
                print("An error has been occured while updating item \(error)")
            }
            
            
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Deselect animasyonunun tamamlanmasını bekleyip reloadData'ı çağırma
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
              tableView.reloadData()
          }

       
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Deselect işlemi tamamlandığında reloadData'ı çağırma
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //            let selectedItem = items?[indexPath.row]
            //            context.delete(selectedItem)
            //            itemArray.remove(at: indexPath.row)
            if let selectedItem = items?[indexPath.row]{
                delete(item: selectedItem)
            }
            
            //            saveItems()
        }
    }
    
    func delete(item: RealmItem){
        do{
            try realm.write{
                realm.delete(item)
            }
        } catch {
            print("Error deleting category \(error)")
        }
        tableView.reloadData()
    }
    
    
    
    //MARK:  Add New Items
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert  = UIAlertController(title: "Add New DoneHub", message: "", preferredStyle:.alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default){
            (action) in
            // What will happen once the user clicks the Add Item button on our UIAlert
            if let safeText = textField.text{
                
                //                let newItem = Item(context: self.context)
                
                
                
                if let safeSelectedCategory = self.selectedCategory {
                    
                    do{
                        
                        try self.realm.write{
                            let newItem = RealmItem()
                            newItem.title = safeText
                            safeSelectedCategory.items.append(newItem)
                            self.realm.add(newItem)
                        }
                    } catch {
                        print("Error saving new items \(error)")
                    }
                }
                //
                
                
                //                newItem.parentCategory = self.selectedCategory
                
                //                self.itemArray.append(newItem)
                
                //                self.saveItems()
            }
            self.tableView.reloadData()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // Handle cancellation, e.g., dismiss the alert
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                var textField = UITextField()
                
                let alert  = UIAlertController(title: "Edit Todo Text", message: "", preferredStyle:.alert)
                
                let addAction = UIAlertAction(title: "Edit", style: .default){
                    (action) in
                    // What will happen once the user clicks the Add Item button on our UIAlert
                    if let safeText = textField.text{
                        
                        var item = self.items?[indexPath.row]
                
                        do{
                            try self.realm.write{
                                item?.title = safeText
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
                    alertTextField.placeholder = "Type a new todo"
                    textField = alertTextField
                    textField.text = self.items?[indexPath.row].title
                }
            
                alert.addAction(addAction)
                alert.addAction(cancelAction)
                present(alert, animated: true)
            }
        }
    }
    
    //    func saveItems(){
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
    
    //    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
    //
    //
    //        let categoryPredicate = NSPredicate(format: "parentCategory.name == %@", selectedCategory!.name!)
    //
    //        if let additionalPredicate = predicate {
    //            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
    //            request.predicate = compoundPredicate
    //        } else {
    //            request.predicate = categoryPredicate
    //        }
    //
    //        do{
    //            itemArray =  try context.fetch(request)
    //        }catch{
    //            print("Error fetching data from context \(error)")
    //        }
    //
    //
    //    }
    
    func loadItems(){
        
        if let safeItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false){
            items = safeItems
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
    
    
    
    
    
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//
//        if (containsOnlySpacesOrEmpty(searchText)){
//            loadItems()
//        } else {
//
//            let request = Item.fetchRequest()
//
//            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//            request.predicate = predicate
//
//            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//
//            request.sortDescriptors = [sortDescriptor]
//
//            //            loadItems(with: request, predicate: predicate)
//        }
//
//        self.tableView.reloadData()
//
//    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        loadItems()
        
        if (!containsOnlySpacesOrEmpty(searchText)){
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            items = items?.filter(predicate).sorted(byKeyPath: "title", ascending: true)
        }
        
        self.tableView.reloadData()
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
    
    func containsOnlySpacesOrEmpty(_ text: String) -> Bool {
        // Trim the input text to remove leading and trailing spaces
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if the trimmed text is either empty or contains only spaces
        return trimmedText.isEmpty
    }
    
}
