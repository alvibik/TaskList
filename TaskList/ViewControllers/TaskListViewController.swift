//
//  ViewController.swift
//  TaskList
//
//  Created by albik on 18.11.2022.
//

import UIKit

//MARK: Protocol declaration

protocol TaskViewControllerDelegate{
    func reloadData()
}

final class TaskListViewController: UITableViewController {
    
    //MARK: - Private properties
    
    private let viewContext = StorageManager.shared.persistentContainer.viewContext
    
    private let cellID = "task"
    private var taskList: [Task] = []
    
    //MARK: - Override methods of super class

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        //view.backgroundColor = .white
        setupNavigationBar()
        fetchData()
    }
    
    //MARK: - Private methods
    
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
    }
    
    @objc private func addNewTask() {
        showAlertAdd(witchTitle: "New task", andMessage: "What do you want to do?")
        let taskVC = TaskViewController()
        taskVC.delegate = self
        present(taskVC, animated: true)
    }
    
    @objc private func addNewTaskWitchVC() {
        let taskVC = TaskViewController()
        taskVC.delegate = self
        present(taskVC, animated: true)
    }
    
    //MARK: - Private methods ShowAlerts
    
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
    private func showAlertEdit(task: Task?, witchTitle title: String, andMessage message: String, completion: @escaping () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let editAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newName = alert.textFields?.first?.text else { return }
                if let task = task {
                    StorageManager.shared.update(task, newName: newName)
                    completion()
                } else {
                    return
                }
            }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "Enter Task"
            textField.text = task?.title
        }

        present(alert, animated: true)
    }

    //MARK: - Private method working witch Core Data
    
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        do {
            try taskList = viewContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
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

//MARK: - Extension TaskListViewController

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
        showAlertEdit(task: task, witchTitle: "Edit task", andMessage: "What do you want to do?"){
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

//MARK: - Extension TaskViewControllerDelegate

extension TaskListViewController: TaskViewControllerDelegate {
    func reloadData() {
        fetchData()
        tableView.reloadData()
    }
}
