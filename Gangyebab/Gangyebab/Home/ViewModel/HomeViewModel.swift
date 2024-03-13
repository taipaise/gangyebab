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
    
    private(set) var inprogressCellModels = CurrentValueSubject<[TodoCellModel], Error>([])
    private(set) var completedCellModels = CurrentValueSubject<[TodoCellModel], Error>([])
    private(set) var date = Date()
    private(set) var homeType = CurrentValueSubject<HomeType,Never>(.day)
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
        var inProgress = inprogressCellModels.value
        var completed = completedCellModels.value
        switch indexPath.section {
        case TodoSection.inProgress.rawValue:
            var item = inProgress[indexPath.row]
            inProgress.remove(at: indexPath.row)
            item.isCompleted.toggle()
            completed.append(item)
        default:
            var item = completed[indexPath.row]
            completed.remove(at: indexPath.row)
            item.isCompleted.toggle()
            inProgress.append(item)
        }
        
        inprogressCellModels.send(inProgress.sorted())
        completedCellModels.send(completed)
    }
    
    private func updateTodo(_ todo: TodoCellModel) {
        var todoCellModels = inprogressCellModels.value
        
        var newTodoCellModels = todoCellModels.filter {
            $0.uuid != todo.uuid
        }
        newTodoCellModels.append(todo)
        inprogressCellModels.send(newTodoCellModels.sorted())
    }
}

// MARK: - Dummy
extension HomeViewModel {
    func makeDummy() {
        var progressDummy = [
            TodoCellModel(title: "현정이랑 데이트1", importance: .high, isCompleted: false, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트2", importance: .medium, isCompleted: false, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트3", importance: .low, isCompleted: false, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트4", importance: .medium, isCompleted: false, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트5", importance: .none, isCompleted: false, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트6", importance: .high, isCompleted: false, repeatType: .none)
        ]
    
        var completeDummy = [
            TodoCellModel(title: "현정이랑 데이트7", importance: .high, isCompleted: true, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트8", importance: .none, isCompleted: true, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트9", importance: .low, isCompleted: true, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트10", importance: .medium, isCompleted: true, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트11", importance: .high, isCompleted: true, repeatType: .none),
            TodoCellModel(title: "현정이랑 데이트12", importance: .high, isCompleted: true, repeatType: .none)
        ]
        
        inprogressCellModels.send(progressDummy.sorted())
        completedCellModels.send(completeDummy)
    }
    
}
