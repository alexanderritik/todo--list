//
//  ToDoListViewController.swift
//  ToDoList
//
/*
 MIT License
 
 Copyright (c) 2018 Gwinyai Nyatsoka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

protocol todoListDelegate: class {
    
    func update(task: ToDoItemModel , index : Int)
    func add(task: ToDoItemModel)
}

class ToDoListViewController: UIViewController  ,UITableViewDataSource , UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!

    var todoItems : [ToDoItemModel] = [ToDoItemModel]()
    
    var selectedItem : ToDoItemModel!
    var index : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ToDo list"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
    
        tableView.delegate = self
        
        tableView.dataSource = self
    
        let todoItem1 = ToDoItemModel(name: "Complete Dynamic Programming", detail: "Complete programming", completionDate : Date())
        let todoItem2 = ToDoItemModel(name: "Complete iOS course", detail: "Complete ios", completionDate : Date())
        let todoItem3 = ToDoItemModel(name: "Dream Projects",  detail: "Complete projects", completionDate : Date())
        let todoItem4 = ToDoItemModel(name: "Dream Projects",  detail: "Complete projects", completionDate : Date())
        
        todoItems.append(todoItem1)
        todoItems.append(todoItem2)
        todoItems.append(todoItem3)
        todoItems.append(todoItem4)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewTask(_ :)), name: NSNotification.Name.init("com.todoList.addTask"), object: nil)
    }
    
    @objc func addNewTask(_ notification : NSNotification){
        
        var todoItem : ToDoItemModel
        
        if let task = notification.object as? ToDoItemModel {
            todoItem = task
        }
        else if let taskdict = notification.userInfo as NSDictionary?{
            guard let task = taskdict["task"] as? ToDoItemModel else { return }
            todoItem = task
        }
        else{
            return
        }
        
        todoItems.append(todoItem)
        
        //sort by date
        todoItems.sort (by: { $0.completionDate < $1.completionDate} )
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.setEditing(false, animated: false)
    }
    
    @objc func addTapped(){
        
        performSegue(withIdentifier: "AddTaskSegue", sender: nil)
        
    }
    
    @objc func editTapped(){
        
        tableView.setEditing(!tableView.isEditing , animated: true)
        
        if tableView.isEditing == true {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done , target: self, action: #selector(editTapped))
        }else{
             navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit , target: self, action: #selector(editTapped))
        }
        
    }
    

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "taskViewSegue" {

            guard let destinationVC = segue.destination as? ToDoDetailsViewController else { return }
            
            guard let (todoItem , index) = sender as? (ToDoItemModel , Int) else  {return}
        
            destinationVC.todoItem = todoItem
            destinationVC.index = index
            destinationVC.delegate = self
        }
        
        if segue.identifier == "AddTaskSegue"{
            
            guard let destinationVC = segue.destination as? AddTaskViewController else { return }
            destinationVC.delegate = self
        }
        
    }
    
    // remove the notification from view
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("com.todoList.addTask"), object: nil)
    }

    
}


extension ToDoListViewController : todoListDelegate {
    
    func update(task: ToDoItemModel ,index :Int) {
        
        todoItems[index] = task
        tableView.reloadData()
    }
    
    func add(task: ToDoItemModel) {

        todoItems.append(task)
        
        todoItems.sort (by: { $0.completionDate > $1.completionDate} )
        tableView.reloadData()
    }
    
}


//for table view func
extension ToDoListViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let todoItem = todoItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItem")!
        
        cell.textLabel?.text = todoItem.name
        
        cell.detailTextLabel?.text = todoItem.isComplete ? "complete":"Incomplete"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
         
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.todoItems.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = todoItems[indexPath.row]
        let item = indexPath.row
        
        let combine = (selectedItem , item)
        
        performSegue(withIdentifier: "taskViewSegue", sender: combine)
        
    }
}


