//
//  TableViewController.swift
//  ToDoApp
//
//  Created by imac4 on 19/02/2020.
//  Copyright © 2020 imac4. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    private let manager = TaskManager.sharedInstance
    private var taskId: String?
    let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.setDelegate(self)
        self.tableView.tableFooterView = UIView()
        self.definesPresentationContext = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        buildSearchController()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? manager.toDoTasks.count : manager.completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Keys.cell.rawValue, for: indexPath) as! ToDoCell
        cell.configureCell(task: indexPath.section == 0 ? manager.toDoTasks[indexPath.row] : manager.completedTasks[indexPath.row])
  
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if manager.toDoTasks.count == 0 {
                return nil
            }
            return Titles.toDoSectionTitle
        case 1:
            if manager.completedTasks.count == 0 {
                return nil
            }
            return Titles.doneSectionTitle
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: Titles.delete) { [weak self] (action, indexPath) in
            if let welf = self {
                let sectionItems = indexPath.section == 0 ? welf.manager.toDoTasks : welf.manager.completedTasks
                let tasks = sectionItems
                welf.executeWithoutReloading {
                    tableView.beginUpdates()
                    let task = tasks[indexPath.row]
                    welf.manager.removeItem(with: task.id)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }
            }
        }
        
        let edit = UITableViewRowAction(style: .normal, title: Titles.edit) { [weak self] (action, indexPath) in
            if let welf = self {
                welf.openEditTask(at: indexPath)
                let sectionTaskId = indexPath.section == 0 ? welf.manager.toDoTasks[indexPath.row].id : welf.manager.completedTasks[indexPath.row].id
                welf.taskId = sectionTaskId
            }
        }
        
        edit.backgroundColor = UIColor.orange
        
        return [delete, edit]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        executeWithoutReloading {
            let isCompleted: Bool
            let task: Task
            tableView.beginUpdates()
            task = indexPath.section == 0 ? manager.toDoTasks[indexPath.row] : manager.completedTasks[indexPath.row]
            isCompleted = manager.changeState(with: task.id)
            manager.removeItem(with: task.id)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if indexPath.section == 0 {
                manager.addTask(task: task)
                tableView.insertRows(at: [IndexPath(row: manager.completedTasks.count - 1, section: 1)], with: .automatic)
            } else {
                manager.addTask(task: task)
                tableView.insertRows(at: [IndexPath(row: manager.toDoTasks.count - 1, section: 0)], with: .automatic)
            }
            let accessoryType: UITableViewCell.AccessoryType = isCompleted ? .checkmark : .none
            tableView.cellForRow(at: indexPath)?.accessoryType = accessoryType
            tableView.endUpdates()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let backItem = UIBarButtonItem()
        backItem.title = Titles.back
        navigationItem.backBarButtonItem = backItem
        let task: Task?
        
        if let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPath(for: cell)!
            let sectionItem = indexPath.section == 0 ? manager.toDoTasks[indexPath.row] : manager.completedTasks[indexPath.row]
            task = sectionItem
        } else {
            task = nil
        }
        if segue.identifier == SegueTypes.detailScreen.rawValue {
            (segue.destination as? DetailViewController)?.delegate = self
            (segue.destination as? DetailViewController)?.task = task
        }
    }
    
    // MARK: - Helpers
    
    private func openEditTask(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        performSegue(withIdentifier: SegueTypes.detailScreen.rawValue, sender: cell)
    }
    
    private func buildSearchController() {
        let searchTextField: UITextField? = { [unowned self] in
            var textField: UITextField?
            self.searchController.searchBar.subviews.forEach({ view in
                view.subviews.forEach({ view in
                    if let view  = view as? UITextField {
                        textField = view
                    }
                })
            })
            return textField
            }()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        /*:
         There is no other solution to change background color of textField
         https://stackoverflow.com/questions/45663169/uisearchcontroller-ios-11-customization
         */
        if let bg = searchTextField?.subviews.first {
            bg.backgroundColor = .white
            bg.layer.cornerRadius = 10
            bg.clipsToBounds = true
        }
        searchController.searchBar.tintColor = .white
    }
    
    private func executeWithoutReloading(_ block: () -> Void) {
        manager.setDelegate(nil)
        block()
        manager.setDelegate(self)
    }

}

// MARK: - TaskCreatorDelegate

extension TableViewController: TaskCreatorDelegate {
    
    func editTask(name: String, description: String?) {
        manager.editItem(at: taskId!, itemName: name, description: description)
        navigationController?.popViewController(animated: true)
    }
    
    func createTask(name: String, description: String?) {
        manager.addItem(itemName: name, description: description)
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - TaskManagerDelegate

extension TableViewController: TaskManagerDelegate {
    
    func taskManagerUpdateTasks(_ manager: TaskManager) {
        tableView.reloadData()
    }
    
}

extension TableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        manager.filterSearchQuerry(by: searchController.searchBar.text ?? "")
    }
    
}

