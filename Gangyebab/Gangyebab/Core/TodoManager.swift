//
//  TodoManager.swift
//  Gangyebab
//
//  Created by 이동현 on 3/21/24.
//

import Foundation
import Combine

final class TodoManager {
    static let shared = TodoManager()
    private let dbManager = DBManager.shared
    private let dateManager = DateManager.shared
    
    private init() {}
    
    func fetchTodos(_ date: String) -> [TodoModel] {
        let today = dateManager.dateToString(Date())
        let repeatRules = dbManager.readRepeatData()
        var todos = dbManager.readTodoDatas(date)
        var appendItems: [TodoModel] = []
        var deleteItems: [TodoModel] = []
        
        for repeatRule in repeatRules {
            //todo에 repeatId가 있는 경우
            if let todo = todos.first(where: { $0.repeatId == repeatRule.repeatId} ) {
                if repeatRule.isDeleted {
                    deleteItems.append(todo)
                }
                
                if
                    todo.title != repeatRule.title ||
                        todo.importance != repeatRule.importance {
                    deleteItems.append(todo)
                    appendItems.append(makeTodoByRepeatRule(repeatRule: repeatRule, date: date))
                }
                    
                
            } else { //todo에 repeatId가 없는 경우
                guard 
                    !repeatRule.isDeleted,
                    dateManager.compare(repeatRule.date, date)
                else { continue }
                
                var newTodo: TodoModel?
                switch repeatRule.repeatType {
                case .none:
                    break
                case .daily:
                    newTodo = makeTodoByRepeatRule(repeatRule: repeatRule, date: date)
                case .weekly:
                    if dateManager.isWeekly(repeatRule.date, date) {
                        newTodo = makeTodoByRepeatRule(repeatRule: repeatRule, date: date)
                    }
                case .monthly:
                    if dateManager.isMonthly(repeatRule.date, date) {
                        newTodo = makeTodoByRepeatRule(repeatRule: repeatRule, date: date)
                    }
                }
                
                if let newTodo = newTodo { appendItems.append(newTodo) }
            }
        }
        
        deleteItems.forEach { todo in
            dbManager.deleteTodoData(todo.uuid)
        }
        
        appendItems.forEach { todo in
            print("ㅋ 다시 추가함: \(todo)")
            dbManager.insertTodoData(todo)
        }
        
        return dbManager.readTodoDatas(date)
    }
    
    func deleteTodo(todo: TodoModel, deleteAll: Bool) {
        
        print("삭제할 todo: \(todo)")
        guard todo.repeatType != .none else {
            dbManager.deleteTodoData(todo.uuid)
            return
        }
        
        guard let repeatRule = dbManager.readRepeatRule(by: todo.repeatId) else { return }
        
        if deleteAll { //이후 반복 이벤트를 모두 삭제 하는 경우
            dbManager.updateRepeatData(
                RepeatRuleModel(
                    repeatId: repeatRule.repeatId,
                    title: repeatRule.title,
                    importance: repeatRule.importance,
                    repeatType: repeatRule.repeatType,
                    date: todo.date,
                    isDeleted: true
                )
            )
        } else { //해당 날짜하나만 삭제하는 경우
            dbManager.updateTodoData(TodoModel(
                uuid: todo.uuid,
                title: todo.title,
                importance: todo.importance,
                repeatType: todo.repeatType,
                date: todo.date,
                repeatId: todo.repeatId,
                isDeleted: true
            ))
        }
    }
    
    func updateTodo(_ todo: TodoModel) {

        guard let originTodo = dbManager.readTodoByUUID(uuid: todo.uuid) else { return }
        if originTodo == todo { return }
        if originTodo.repeatType == todo.repeatType {
            if originTodo.repeatType != .none {
                dbManager.updateRepeatData(
                    RepeatRuleModel(
                        repeatId: originTodo.repeatId,
                        title: todo.title,
                        importance: todo.importance,
                        repeatType: todo.repeatType,
                        date: todo.date
                    )
                )
            }
            dbManager.updateTodoData(TodoModel(
                uuid: todo.uuid,
                title: todo.title,
                importance: todo.importance,
                isCompleted: todo.isCompleted,
                repeatType: todo.repeatType,
                date: todo.date,
                repeatId: originTodo.repeatId
            ))
            return
        }
        
        guard let repeatRule = dbManager.readRepeatRule(by: originTodo.repeatId) else {
            let id = insertRepeat(todo)
            dbManager.updateTodoData(
                TodoModel(
                    uuid: todo.uuid,
                    title: todo.title,
                    importance: todo.importance,
                    repeatType: todo.repeatType,
                    date: todo.date,
                    repeatId: id
                )
            )
            return
        }

        dbManager.updateRepeatData(
            RepeatRuleModel(
                repeatId: repeatRule.repeatId,
                title: repeatRule.title,
                importance: repeatRule.importance,
                repeatType: repeatRule.repeatType,
                date: todo.date,
                isDeleted: true
            )
        )
        
        if todo.repeatType != .none {
            let id = insertRepeat(todo)
            dbManager.updateTodoData(
                TodoModel(
                    uuid: todo.uuid,
                    title: todo.title,
                    importance: todo.importance,
                    repeatType: todo.repeatType,
                    date: todo.date,
                    repeatId: id
                )
            )
        } else {
            dbManager.updateTodoData(
                TodoModel(
                    uuid: todo.uuid,
                    title: todo.title,
                    importance: todo.importance,
                    repeatType: todo.repeatType,
                    date: todo.date
                )
            )
        }
    }
    
    func insertTodo(_ todo: TodoModel) -> Bool {
        if todo.repeatType == .none {
            return dbManager.insertTodoData(todo)
        }
        
        let id = dbManager.countRules() + 1
        return dbManager.insertRepeatData(
            RepeatRuleModel(
                repeatId: id,
                title: todo.title,
                importance: todo.importance,
                repeatType: todo.repeatType,
                date: todo.date,
                isDeleted: false
            )
        )
    }
    
    @discardableResult
    private func insertRepeat(_ todo: TodoModel) -> Int {
        let id = dbManager.countRules() + 1
        dbManager.insertRepeatData(RepeatRuleModel(
            repeatId: id,
            title: todo.title,
            importance: todo.importance,
            repeatType: todo.repeatType,
            date: todo.date
        ))
        return id
    }
    
    private func makeTodoByRepeatRule(repeatRule: RepeatRuleModel, date: String) -> TodoModel {
        return TodoModel(
            title: repeatRule.title,
            importance: repeatRule.importance,
            repeatType: repeatRule.repeatType,
            date: date,
            repeatId: repeatRule.repeatId
        )
    }
}
