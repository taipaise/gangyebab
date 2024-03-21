//
//  HomeViewModel.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import Foundation
import Combine
import WidgetKit

final class HomeViewModel: ViewModel {
    enum Input {
        case toggleHomeType
        case toggleComplete(_ indexPath: IndexPath)
        case nextButton
        case previousButton
        case addTodo(_ todo: TodoModel)
        case updateTodo(_ todo: TodoModel)
        case deleteTodo(_ indexPath: IndexPath, deleteAll: Bool)
        case todayButtonTapped
        case dateSelected(_ date: Date)
        case calendarSwipe(_ date: Date)
        case viewWillAppear
    }
    
    @Published private(set) var isToday = true
    private(set) var homeType = CurrentValueSubject<HomeType, Never>(.day)
    private(set) var dateString = CurrentValueSubject<String, Never>("")
    private(set) var monthString = CurrentValueSubject<String, Never>("")
    private(set) var cellModels = CurrentValueSubject<TodoCellModels, Error>(TodoCellModels(inProgress: [], completed: []))
    private(set) var inprogressCellModels: [TodoModel] = []
    private(set) var completedCellModels: [TodoModel] = []
    private(set) var date = CurrentValueSubject<Date, Never>(Date())
    private(set) var calendarPage = CurrentValueSubject<Date, Never>(Date())
    private var cancellables: Set<AnyCancellable> = []
    private let todoManager = TodoManager.shared
    private let dateManager = DateManager.shared
    
    func action(_ input: Input) {
        switch input {
        case .toggleHomeType:
            toggleHomeType()
        case .toggleComplete(let indexPath):
            toggleComplete(indexPath)
        case .nextButton:
            goNextDay()
        case .previousButton:
            goPrevioudDay()
        case .addTodo(let todo):
            addTodo(todo)
        case .deleteTodo(let indexPath, let deleteAll):
            deleteTodo(indexPath, deleteAll: deleteAll)
        case .updateTodo(let todo):
            updateTodo(todo)
        case .todayButtonTapped:
            setDate(Date())
        case .dateSelected(let date):
            setDate(date)
        case .calendarSwipe(let date):
            calendarSwipe(date)
        case .viewWillAppear:
            fetchTodoList(date.value)
        }
    }
    
    init() {
        fetchTodoList(Date())
        binding()
        monthString.send(dateManager.dateToStringMonth(Date()))
    }
    
    private func binding() {
        let todayString = dateManager.dateToStringForHome(Date())
        
        date.sink { [weak self] date in
            guard let dateString = self?.dateManager.dateToStringForHome(date) else { return }
            self?.dateString.send(dateString)
            self?.isToday = dateString == todayString
            self?.fetchTodoList(date)
        }.store(in: &cancellables)
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
        todoManager.insertTodo(todo)
        fetchTodoList(date.value)
    }
    
    private func updateTodo(_ todo: TodoModel) {
        print("update")
        todoManager.updateTodo(todo)
        fetchTodoList(date.value)
    }
    
    private func deleteTodo(_ indexPath: IndexPath, deleteAll: Bool) {
        var item: TodoModel
        switch indexPath.section {
        case TodoSection.inProgress.rawValue:
            item = inprogressCellModels[indexPath.row]
        default:
            item = completedCellModels[indexPath.row]
        }
        
        todoManager.deleteTodo(todo: item, deleteAll: deleteAll)
        fetchTodoList(date.value)
    }
    
    private func goNextDay() {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        switch homeType.value {
        case .day:
            dateComponents.day = 1
            if let nextDay = calendar.date(byAdding: dateComponents, to: date.value) {
                date.send(nextDay)
            }
        case .month:
            dateComponents.month = 1
            if let nextMonth = calendar.date(byAdding: dateComponents, to: calendarPage.value) {
                calendarPage.send(nextMonth)
            }
        }
    }
    
    private func goPrevioudDay() {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        switch homeType.value {
        case .day:
            dateComponents.day = -1
            
            if let previousDay = calendar.date(byAdding: dateComponents, to: date.value) {
                date.send(previousDay)
            }
        case .month:
            dateComponents.month = -1
            if let nextMonth = calendar.date(byAdding: dateComponents, to: calendarPage.value) {
                calendarPage.send(nextMonth)
            }
        }
    }
    
    private func setDate(_ date: Date) {
        calendarPage.send(date)
        self.date.send(date)
    }
    
    private func calendarSwipe(_ date: Date) {
        calendarPage.send(date)
        monthString.send(dateManager.dateToStringMonth(date))
    }
}

// MARK: - method
extension HomeViewModel {
    private func fetchTodoList(_ date: Date) {
        let dateString = dateManager.dateToString(date)
        let todos = todoManager.fetchTodos(dateString)
        
        inprogressCellModels = todos.filter { !$0.isCompleted && !$0.isDeleted }.sorted()
        completedCellModels = todos.filter { $0.isCompleted && !$0.isDeleted }
        
        cellModels.send(
            TodoCellModels(
                inProgress: inprogressCellModels,
                completed: completedCellModels
            )
        )
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct TodoCellModels: Hashable {
    var inProgress: [TodoModel]
    var completed: [TodoModel]
}
