//
//  String+TextHelpers.swift
//  ToDoApp
//
//  Created by imac4 on 04/03/2020.
//  Copyright © 2020 imac4. All rights reserved.
//

import Foundation

extension String {
    func noWhiteSpaces() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
