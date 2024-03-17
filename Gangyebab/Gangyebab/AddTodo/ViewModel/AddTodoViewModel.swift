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
    private(set) var title = CurrentValueSubject<String, Never>("")
    private(set) var isEditing = false
    private let dateManager = DateManager.shared
    private var todoCellModel: TodoModel?
    
    func configure(_ todo: TodoModel) {
        todoCellModel = todo
        title.send(todo.title)
        importance.send(todo.importance)
        repeatType.send(todo.repeatType)
        isEditing = true 
    }
    
    func action(_ input: Input) {
        switch input {
        case .updateImportance(let tag):
            changeImportance(tag)
        case .updateRepeatType(let type):
            changeRepeatType(type)
        case .updateTitle(let title):
            changeTitle(title)
        }
    }
}

// MARK: - Action
extension AddTodoViewModel {
    func getTodo() -> TodoModel {
        if 
            let todo = todoCellModel,
            isEditing
        {
            return TodoModel(
                uuid: todo.uuid,
                title: title.value,
                importance: importance.value,
                repeatType: repeatType.value,
                date: todo.date
            )
        } else {
            return TodoModel(
                title: title.value,
                importance: importance.value,
                repeatType: repeatType.value,
                date: dateManager.dateToString(Date())
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
    
    private func changeTitle(_ title: String) {
        self.title.send(title)
    }
}
