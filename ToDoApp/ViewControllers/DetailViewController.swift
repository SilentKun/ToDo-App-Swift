//
//  ViewController2.swift
//  ToDoApp
//
//  Created by imac4 on 20/02/2020.
//  Copyright © 2020 imac4. All rights reserved.
//

import UIKit

protocol TaskCreatorDelegate: class {
    func createTask(name: String, description: String?)
    func editTask(name: String, description: String?)
}

class DetailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var taskNameField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var addTaskButton: UIButton!
    weak var delegate: TaskCreatorDelegate!
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskNameField.delegate = self
        addTaskButton.isEnabled = false
        navigationItem.largeTitleDisplayMode = .never
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        if let model = task {
            taskNameField.text = model.taskName
            descriptionTextView.text = model.description
            addTaskButton.setTitle(Titles.editTask, for: .normal)
            addTaskButton.isEnabled = true
        }
    }
    
    @IBAction func addTask(_ sender: Any) {
        let name: String = taskNameField.text ?? ""
        let description: String = descriptionTextView.text.noWhiteSpaces()
        if task != nil {
            delegate?.editTask(name: name, description: description)
        } else {
            delegate?.createTask(name: name, description: description)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        addTaskButton.isEnabled = !text.isEmpty
        return true
    }
    
}

