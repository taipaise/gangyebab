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
    @Published var date: String
    
    private let dbManager = DBManager.shared
    private let dateManager = DateManager.shared
    
    init() {
        date = dateManager.dateToStringWidget(Date())
        fetchTodos()
    }
    
    func fetchTodos() {
        let currentDate = dateManager.dateToString(Date())
        todos = dbManager.readTodoDatas(currentDate).sorted()
        print(todos)
    }
    
    func todoTap(_ todo: TodoModel) {
        print("todo 탭")
    }
}
