//
//  TaskViewController.swift
//  TaskList
//
//  Created by albik on 18.11.2022.
//

import UIKit

final class TaskViewController: UIViewController {
    
    //MARK: - Public properties
    
    var delegate: TaskViewControllerDelegate!
    
    //MARK: - Private properties
    
    private let viewContex = StorageManager.shared.persistentContainer.viewContext
    
    private lazy var taskTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter Task"
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        createButton(whithTitle: "Save Task", andColor: .systemGray3,
                     action: UIAction { [unowned self] _ in save()
        })
    }()
    
    private lazy var cancelButton: UIButton = {
        createButton(whithTitle: "Cancel", andColor: .systemRed,
                     action: UIAction { [unowned self] _ in  dismiss(animated: true)
        })
    }()
    
    //MARK: - Override methods of super class
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSubViews(taskTextField, saveButton, cancelButton)
        setConstraints()
    }
    
    //MARK: - Private methods
    
    private func setupSubViews(_ subViews: UIView...) {
        subViews.forEach { subView in
            view.addSubview(subView)
        }
    }
    
    private func setConstraints() {
        taskTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            taskTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            taskTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            taskTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: taskTextField.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60)
        ])
    }
    
    private func createButton(whithTitle title: String, andColor color: UIColor, action: UIAction) -> UIButton {
        var attributes = AttributeContainer()
        attributes.font = UIFont.boldSystemFont(ofSize: 18)
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.attributedTitle = AttributedString(title, attributes: attributes)
        buttonConfig.baseBackgroundColor = color
        return UIButton(configuration: buttonConfig, primaryAction: action)
    }
    
    private func save() {
        let task = Task(context: viewContex)
        task.title = taskTextField.text
        
        if viewContex.hasChanges {
            do {
                try viewContex.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        delegate.reloadData()
        dismiss(animated: true)
    }
}
