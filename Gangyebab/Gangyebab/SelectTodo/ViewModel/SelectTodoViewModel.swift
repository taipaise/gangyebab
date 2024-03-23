//
//  SelectTodoViewModel.swift
//  Gangyebab
//
//  Created by 이동현 on 3/23/24.
//

import Foundation
import Combine

final class SelectTodoViewModel: ViewModel {
    enum Input {
        case selectTodo(_ indexPath: IndexPath)
        case add
    }
    
    private(set) var cellModels = CurrentValueSubject<[TodoModel], Error>([])
    private(set) var selectedTodos = CurrentValueSubject<[TodoModel], Never>([])
    private var todoManager = TodoManager.shared
    private var dateManager = DateManager.shared
    
    init() {
        let currentDate = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.day = -1

        guard let yesterday = calendar.date(byAdding: dateComponents, to: currentDate)  else {
            fatalError("어제를 구할 수 없음")
        }
        
        let dateString = dateManager.dateToString(yesterday)
        let yesterdayTodos = todoManager.fetchTodos(dateString)
        
        let cellModels = yesterdayTodos.filter({
            $0.isCompleted == false
            && $0.repeatType != .daily
            && $0.isDeleted == false
        })
        
        self.cellModels.send(cellModels)
    }
    
    func action(_ input: Input) {
        switch input {
        case .selectTodo(let indexPath):
            selectTodo(indexPath)
        case .add:
            addTodos()
        }
    }
}

extension SelectTodoViewModel {
    private func selectTodo(_ indexPath: IndexPath) {
        let todos = cellModels.value
        let todo = todos[indexPath.row]
        var newSelectedTodos = selectedTodos.value
        
        
        
        if let index = newSelectedTodos.firstIndex(where: { $0.uuid == todo.uuid }) {
            newSelectedTodos.remove(at: index)
        } else {
            newSelectedTodos.append(todo)
        }

        selectedTodos.send(newSelectedTodos)
    }
    
    private func addTodos() {
        let todos = selectedTodos.value
        let todayString = dateManager.dateToString(Date())
        todos.forEach { todo in
            let newTodo = TodoModel(
                title: todo.title,
                importance: todo.importance,
                isCompleted: false,
                repeatType: .none,
                date: todayString,
                repeatId: -1,
                isDeleted: false
            )
            
            todoManager.insertTodo(newTodo)
        }
    }
}
