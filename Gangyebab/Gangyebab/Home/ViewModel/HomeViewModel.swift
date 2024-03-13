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
}

// MARK: - Dummy
extension HomeViewModel {
    func makeDummy() {
        var progressDummy = [
            TodoCellModel(content: "현정이랑 데이트1", importance: .high, isCompleted: false),
            TodoCellModel(content: "현정이랑 데이트2", importance: .medium, isCompleted: false),
            TodoCellModel(content: "현정이랑 데이트3", importance: .low, isCompleted: false),
            TodoCellModel(content: "현정이랑 데이트4", importance: .medium, isCompleted: false),
            TodoCellModel(content: "현정이랑 데이트5", importance: .none, isCompleted: false),
            TodoCellModel(content: "현정이랑 데이트6", importance: .high, isCompleted: false)
        ]
    
        var completeDummy = [
            TodoCellModel(content: "현정이랑 데이트7", importance: .high, isCompleted: true),
            TodoCellModel(content: "현정이랑 데이트8", importance: .none, isCompleted: true),
            TodoCellModel(content: "현정이랑 데이트9", importance: .low, isCompleted: true),
            TodoCellModel(content: "현정이랑 데이트10", importance: .medium, isCompleted: true),
            TodoCellModel(content: "현정이랑 데이트11", importance: .high, isCompleted: true),
            TodoCellModel(content: "현정이랑 데이트12", importance: .high, isCompleted: true)
        ]
        
        inprogressCellModels.send(progressDummy.sorted())
        completedCellModels.send(completeDummy)
    }
    
}
