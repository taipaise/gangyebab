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
        case updateTodo(_ todo: TodoCellModel)
    }
    
    private(set) var homeType = CurrentValueSubject<HomeType,Never>(.day)
    private(set) var cellModels = CurrentValueSubject<TodoCellModels, Error>(TodoCellModels(inProgress: [], completed: []))
    private(set) var inprogressCellModels: [TodoCellModel] = []
    private var completedCellModels: [TodoCellModel] = []
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
        }
    }
    
    init() {
        makeDummy()
    }
}

// MARK: - Action
extension HomeViewModel {
    private func toggleHomeType() {
        if homeType.value == .day {
            homeType.send(.month)
        } else {
            homeType.send(.day)
        }
    }
    
    private func toggleComplete(_ indexPath: IndexPath) {
        if indexPath.section == 0 {
            print(indexPath.row)
            print(inprogressCellModels[indexPath.row])
        }
        
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
    
    private func updateTodo(_ todo: TodoCellModel) {
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
}

struct TodoCellModels: Hashable {
    var inProgress: [TodoCellModel]
    var completed: [TodoCellModel]
}

// MARK: - Dummy
extension HomeViewModel {
    func makeDummy() {
        let progressDummy = [
            TodoCellModel(title: "현정이랑 데이트1", importance: .high, isCompleted: false, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트2", importance: .medium, isCompleted: false, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트3", importance: .low, isCompleted: false, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트4", importance: .medium, isCompleted: false, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트5", importance: .none, isCompleted: false, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트6", importance: .high, isCompleted: false, repeatType: .none)
        ]
    
        let completeDummy = [
            TodoCellModel(title: "현정이랑 데이트7", importance: .high, isCompleted: true, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트8", importance: .none, isCompleted: true, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트9", importance: .low, isCompleted: true, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트10", importance: .medium, isCompleted: true, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트11", importance: .high, isCompleted: true, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트12", importance: .high, isCompleted: true, repeatType: .none)
        ]
        
        inprogressCellModels = progressDummy
        completedCellModels = completeDummy
        inprogressCellModels.sort()
        cellModels.send(TodoCellModels(inProgress: inprogressCellModels, completed: completedCellModels))
    }
}
