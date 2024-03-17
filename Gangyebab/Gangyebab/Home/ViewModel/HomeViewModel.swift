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
        case editTapped
        case checkTodo(_ indexPath: IndexPath)
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
        case .updateTodo(let todo):
            updateTodo(todo)
        case .deleteTodo:
            deleteTodo()
        case .editTapped:
            toggleEditState()
        case .checkTodo(let indexPath):
            checkTodo(indexPath)
        }
    }
    
    init() {
        makeDummy()
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
        switch indexPath.section {
        case TodoSection.inProgress.rawValue:
            var item = inprogressCellModels[indexPath.row]
            inprogressCellModels = inprogressCellModels.filter {
                item.uuid != $0.uuid
            }
            item.isCompleted = true
            completedCellModels.append(item)
        default:
            var item = completedCellModels[indexPath.row]
            completedCellModels = completedCellModels.filter {
                item.uuid != $0.uuid
            }
            item.isCompleted = false
            inprogressCellModels.append(item)
            inprogressCellModels.sort()
        }
        
        cellModels.send(TodoCellModels(
            inProgress: inprogressCellModels,
            completed: completedCellModels
        ))
    }
    
    private func updateTodo(_ todo: TodoModel) {
        inprogressCellModels = inprogressCellModels.filter {
            $0.uuid != todo.uuid
        }
        inprogressCellModels.append(todo)
        inprogressCellModels.sort()
        
        cellModels.send(TodoCellModels(
            inProgress: inprogressCellModels,
            completed: completedCellModels
        ))
    }
    
    private func deleteTodo() {
        inprogressCellModels = inprogressCellModels.filter { !$0.isChecked }
        completedCellModels = completedCellModels.filter { !$0.isChecked }
        let newCellModels = TodoCellModels(
            inProgress: inprogressCellModels,
            completed: completedCellModels
        )
        cellModels.send(newCellModels)
        
        if isEditing { toggleEditState() }
    }
    
    private func toggleEditState() {
        isEditing.toggle()
        
        inprogressCellModels = inprogressCellModels.map {
            var newCellModel = $0
            newCellModel.isEditing = isEditing
            newCellModel.isChecked = false
            return newCellModel
        }
        
        completedCellModels = completedCellModels.map {
            var newCellModel = $0
            newCellModel.isEditing = isEditing
            newCellModel.isChecked = false
            return newCellModel
        }
        
        let newCellModels = TodoCellModels(
            inProgress: inprogressCellModels,
            completed: completedCellModels
        )
        
        cellModels.send(newCellModels)
    }
    
    private func checkTodo(_ indexPath: IndexPath) {
        if indexPath.section == TodoSection.inProgress.rawValue {
            inprogressCellModels[indexPath.row].isChecked.toggle()
        } else {
            completedCellModels[indexPath.row].isChecked.toggle()
        }
        
        let newCellModels = TodoCellModels(
            inProgress: inprogressCellModels,
            completed: completedCellModels
        )
        cellModels.send(newCellModels)
    }
}

struct TodoCellModels: Hashable {
    var inProgress: [TodoModel]
    var completed: [TodoModel]
}

// MARK: - Dummy
extension HomeViewModel {
    func makeDummy() {
        let progressDummy = [
            TodoModel(title: "현정이랑 데이트1", importance: .high, isCompleted: false, repeatType: .none),
            TodoModel(title: "현정이랑 데이트2", importance: .medium, isCompleted: false, repeatType: .none),
            TodoModel(title: "현정이랑 데이트3", importance: .low, isCompleted: false, repeatType: .none),
            TodoModel(title: "현정이랑 데이트4", importance: .medium, isCompleted: false, repeatType: .none),
            TodoModel(title: "현정이랑 데이트5", importance: .none, isCompleted: false, repeatType: .none),
            TodoModel(title: "현정이랑 데이트6", importance: .high, isCompleted: false, repeatType: .none)
        ]
    
        let completeDummy = [
            TodoModel(title: "현정이랑 데이트7", importance: .high, isCompleted: true, repeatType: .none),
            TodoModel(title: "현정이랑 데이트8", importance: .none, isCompleted: true, repeatType: .none),
            TodoModel(title: "현정이랑 데이트9", importance: .low, isCompleted: true, repeatType: .none),
            TodoModel(title: "현정이랑 데이트10", importance: .medium, isCompleted: true, repeatType: .none),
            TodoModel(title: "현정이랑 데이트11", importance: .high, isCompleted: true, repeatType: .none),
            TodoModel(title: "현정이랑 데이트12", importance: .high, isCompleted: true, repeatType: .none)
        ]
        
        inprogressCellModels = progressDummy
        completedCellModels = completeDummy
        inprogressCellModels.sort()
        cellModels.send(TodoCellModels(inProgress: inprogressCellModels, completed: completedCellModels))
    }
}
