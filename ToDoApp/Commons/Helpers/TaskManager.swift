//
//  TaskManager.swift
//  ToDoApp
//
//  Created by imac4 on 25/02/2020.
//  Copyright © 2020 imac4. All rights reserved.
//

import Foundation

protocol TaskManagerDelegate: class {
    func taskManagerUpdateTasks(_ manager: TaskManager)
}

class TaskManager {
    
    static let sharedInstance = TaskManager()
    private(set) var tasks = [Task]() {
        didSet {
            let data = try? JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: Keys.userTasks.rawValue)
            computeSections()
        }
    }
    private(set) var completedTasks: [Task] = []
    private(set) var toDoTasks: [Task] = []
    private(set) var searchQuerry = "" {
        didSet {
            computeSections()
        }
    }
    private weak var delegate: TaskManagerDelegate?
    
    private init() {
        tasks = fetchTasks()
        computeSections()
    }
    
    func addItem(itemName: String, description: String?, isCompleted: Bool = false) {
        let item: Task = Task(id: UUID().uuidString, taskName: itemName, description: description, isCompleted: isCompleted)
        addTask(task: item)
    }
    
    func addTask(task: Task) {
        tasks.append(task)
    }
    
    func removeItem(with id: String) {
        tasks.removeAll {$0.id == id}
    }
    
    func changeState(with id: String) -> Bool {
        guard let task = tasks.first(where: { (item) -> Bool in
            item.id == id
        }) else { return false }
        task.isCompleted = !task.isCompleted
        computeSections()
        return task.isCompleted
    }
    
    func editItem(at id: String, itemName: String?, description: String?) {
        guard let index = tasks.firstIndex(where: { (item) -> Bool in
            item.id == id
        }) else { return }
        let task = tasks[index]
        task.taskName = itemName
        task.description = description
        tasks[index] = task
    }
    
    func filterSearchQuerry(by querry: String) {
        searchQuerry = querry
    }
    
    func setDelegate(_ delegate: TaskManagerDelegate?) {
        self.delegate = delegate
    }
    
    // MARK: - Helpers
    
    private func fetchTasks() -> [Task] {
        if let data = UserDefaults.standard.data(forKey: Keys.userTasks.rawValue),
            let tasks = try? JSONDecoder().decode([Task].self, from: data) {
                return tasks
        }
        return []
    }
    
    private func filterTasks() -> [Task] {
        let searchText = searchQuerry.lowercased()
        guard searchText.count > 0 else { return tasks }
        return tasks.filter({ (task: Task) -> Bool in
            return task.taskName.lowercased().contains(searchText) ||
                task.description?.lowercased().contains(searchText) ?? false
        })
    }
    
    private func computeSections() {
        let filteredTasks = filterTasks()
        completedTasks = filteredTasks.filter({ $0.isCompleted })
        toDoTasks = filteredTasks.filter({ !$0.isCompleted })
        delegate?.taskManagerUpdateTasks(self)
    }
    
}
