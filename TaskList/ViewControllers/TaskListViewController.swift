//
//  ViewController.swift
//  TaskList
//
//  Created by albik on 18.11.2022.
//

import UIKit

protocol TaskViewControllerDelegate{
    func reloadData()
}

final class TaskListViewController: UITableViewController {
    
    private let viewContext = StorageManager.shared.persistentContainer.viewContext
    //private let viewContex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        //view.backgroundColor = .white
        setupNavigationBar()
        fetchData()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .systemGray5
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        let addWitchVC = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTaskWitchVC))
        addWitchVC.tintColor = UIColor.systemGray
        
        let addWitchAlertController = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask))
        
        navigationController?.navigationBar.tintColor = .white
        navigationItem.rightBarButtonItems = [addWitchAlertController, addWitchVC]
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            barButtonSystemItem: tableView.isEditing ? .done : .edit,
//                    //.edit,
//            target:
//                self,
//            action: #selector(toggleEdit)
//        )
    }
    
    @objc private func addNewTask() {
        showAlertAdd(witchTitle: "New task", andMessage: "What do you want to do?")
//        let taskVC = TaskViewController()
//        taskVC.delegate = self
//        present(taskVC, animated: true)
    }
    
    @objc private func addNewTaskWitchVC() {
        
        let taskVC = TaskViewController()
        taskVC.delegate = self
        present(taskVC, animated: true)
    }
    
//    @objc private func toggleEdit() {
//        tableView.setEditing(!tableView.isEditing, animated: true)
////        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: (tableView.isEditing) ? .done : .edit, menu: UIMenu?)
//
////        if tableView.isEditing {
////                rightBarButtonItem?.title = "Done"
////            } else {
////                rightBarButtonItem?.title = "Edit"
////            }
//    }
    
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        do {
            try taskList = viewContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func showAlertAdd(witchTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            save(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "Enter Task"
        }
        
        present(alert, animated: true)
    }
    private func showAlertEdit(witchTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let editAction = UIAlertAction(title: "Edit", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            //StorageManager.shared.update(task, newName: task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "Enter Task"
        }
        
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        let task = Task(context: viewContext)
        task.title = taskName
        taskList.append(task)
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList[indexPath.row]
            viewContext.delete(task)
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = taskList[indexPath.row]
//        showAlertEdit(witchTitle: task) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
//    func tableview(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let moveTaskTemp = taskList[sourceIndexPath.item]
//        taskList.remove(at: sourceIndexPath.item)
//        taskList.insert(moveTaskTemp, at: destinationIndexPath.item)
//    }
//}

extension TaskListViewController: TaskViewControllerDelegate {
    func reloadData() {
        fetchData()
        tableView.reloadData()
    }
}

//// MARK: - Alert Controller
//extension TaskListViewController {
//    private func showAlert1(task: Task? = nil, completion: (() -> Void)? = nil){
//    let title = task != nil ? "Update Task" : "New Task"
//    let alert = UIAlertController.createAlertController(withTitle: title)
//    alert.action (task: task) { taskName in
//        if let task = task, let completion = completion {
//            StorageManager.shared.update (task, newName: taskName)
//            completion ()
//        } else {
//            self.save (taskName: taskName)
//        }
//    }
//    present (alert, animated: true)
//    }
//}

