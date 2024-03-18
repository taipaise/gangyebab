//
//  WidgetViewModel.swift
//  GangyebabWidgetExtension
//
//  Created by 이동현 on 3/18/24.
//

import Foundation
import Combine

final class WidgetViewModel: ObservableObject {
    @Published var todos: [TodoModel] = []
    
    private let dbManager = DBManager.shared
    private let dateManager = DateManager.shared
    
    init() {
        fetchTodos()
    }
    
    func fetchTodos() {
        let currentDate = dateManager.dateToString(Date())
        todos = dbManager.readTodoData(currentDate)
        print(todos)
    }
}
