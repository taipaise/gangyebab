//
//  AddTodoViewModel.swift
//  Gangyebab
//
//  Created by 이동현 on 3/13/24.
//

import Foundation
import Combine

final class AddTodoViewModel: ViewModel {
    enum Input {
        case updateImportance(_ tag: Int)
        case updateRepeatType(_ type: RepeatType)
        case updateTitle(_ title: String)
    }

    private(set) var importance = CurrentValueSubject<Importance, Never>(.none)
    private(set) var repeatType = CurrentValueSubject<RepeatType, Never>(.none)
    private var title = ""
    private var todoCellModel: TodoCellModel?
    
    func configure(_ todo: TodoCellModel) {
        todoCellModel = todo
        title = todo.title
        importance.send(todo.importance)
        repeatType.send(todo.repeatType)
    }
    
    func action(_ input: Input) {
        switch input {
        case .updateImportance(let tag):
            changeImportance(tag)
        case .updateRepeatType(let type):
            changeRepeatType(type)
        case .updateTitle(let title):
            print("update title to \(title)")
            self.title = title
        }
    }
}

// MARK: - Action
extension AddTodoViewModel {
    func getTodo() -> TodoCellModel {
        if let todo = todoCellModel {
            print(title)
            return TodoCellModel(
                uuid: todo.uuid,
                title: title,
                importance: importance.value,
                repeatType: repeatType.value
            )
        } else {
            print(title)
            return TodoCellModel(
                title: title,
                importance: importance.value,
                repeatType: repeatType.value
            )
        }
    }
    
    private func changeImportance(_ tag: Int) {
        switch tag {
        case Importance.none.rawValue:
            importance.send(.none)
        case Importance.low.rawValue:
            importance.send(.low)
        case Importance.medium.rawValue:
            importance.send(.medium)
        default:
            importance.send(.high)
        }
    }
    
    private func changeRepeatType(_ type: RepeatType) {
        repeatType.send(type)
    }
}
