//
//  ToDoItems.swift
//  ToDoApp
//
//  Created by imac4 on 20/02/2020.
//  Copyright © 2020 imac4. All rights reserved.
//

import Foundation

class Task: Codable {
    var id: String
    var taskName: String!
    var description: String?
    var isCompleted: Bool
    
    init(id: String, taskName: String, description: String?, isCompleted: Bool) {
        self.id = id
        self.taskName = taskName
        self.description = description
        self.isCompleted = isCompleted
    }
    
}
