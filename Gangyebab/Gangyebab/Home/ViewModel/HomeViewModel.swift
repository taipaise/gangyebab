//
//  HomeViewModel.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import Foundation
import Combine

final class HomeViewModel: ViewModel {
    enum Input {
        case toggleHomeType
        case toggleComplete(_ indexPath: IndexPath)
        case nextButton
        case previousButton
        case addTodo(_ todo: TodoModel)
        case updateTodo(_ todo: TodoModel)
        case deleteTodo
    }
    
    @Published private(set) var isEditing = false
    private(set) var homeType = CurrentValueSubject<HomeType,Never>(.day)
    private(set) var cellModels = CurrentValueSubject<TodoCellModels, Error>(TodoCellModels(inProgress: [], completed: []))
    private(set) var inprogressCellModels: [TodoModel] = []
    private var completedCellModels: [TodoModel] = []
    private(set) var date = Date()
    private var cancellables: Set<AnyCancellable> = []
    private let dbManager = DBManager.shared
    private let dateManager = DateManager.shared
    
    func action(_ input: Input) {
        switch input {
        case .toggleHomeType:
            toggleHomeType()
        case .toggleComplete(let indexPath):
            toggleComplete(indexPath)
        case .nextButton:
            print()
        case .previousButton:
            print()
        case .addTodo(let todo):
            addTodo(todo)
        case .deleteTodo:
            deleteTodo()
        case .updateTodo(let todo):
            updateTodo(todo)
        }
    }
    
    init() {
        fetchTodoList(Date())
    }
}

// MARK: - Action
extension HomeViewModel {
    private func toggleHomeType() {
        if isEditing { toggleEditState() }
        
        if homeType.value == .day {
            homeType.send(.month)
        } else {
            homeType.send(.day)
        }
    }
    
    private func toggleComplete(_ indexPath: IndexPath) {
        var item: TodoModel
        switch indexPath.section {
        case TodoSection.inProgress.rawValue:
            item = inprogressCellModels[indexPath.row]
        default:
            item = completedCellModels[indexPath.row]
        }
        
        item.isCompleted.toggle()
        updateTodo(item)
    }
    
    private func addTodo(_ todo: TodoModel) {
        if dbManager.insertTodoData(todo) {
            fetchTodoList(date)
        }
    }
    
    private func updateTodo(_ todo: TodoModel) {
        if dbManager.updateTodoData(todo) {
            fetchTodoList(date)
        }
    }
    
    private func deleteTodo() {
    }
    
    private func toggleEditState() {
        
    }
    
    private func checkTodo(_ indexPath: IndexPath) {
        
    }
}

// MARK: - method
extension HomeViewModel {
    private func fetchTodoList(_ date: Date) {
        let dateString = dateManager.dateToString(date)
        let todosOfDate = dbManager.readTodoData(dateString)
        
        inprogressCellModels = todosOfDate.filter { !$0.isCompleted }.sorted()
        completedCellModels = todosOfDate.filter { $0.isCompleted }
        
        cellModels.send(
            TodoCellModels(
                inProgress: inprogressCellModels,
                completed: completedCellModels
            )
        )
    }
}

struct TodoCellModels: Hashable {
    var inProgress: [TodoModel]
    var completed: [TodoModel]
}
