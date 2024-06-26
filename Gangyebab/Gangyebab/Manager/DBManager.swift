//
//  DBManager.swift
//  Gangyebab
//
//  Created by 이동현 on 3/17/24.
//
import UIKit
import SQLite3

import UIKit
final class DBManager {
    static let shared = DBManager()
    
    typealias IsSuccess = Bool
    var db: OpaquePointer?
    var path = "todo.sqlite"
    
    private init() {
        createDB()
    }
    
    func isTableExists(tableName: String) -> Bool {
        let query = "SELECT name FROM sqlite_master WHERE type='table' AND name=?;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (tableName as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                sqlite3_finalize(statement)
                return true
            }
        }
        
        sqlite3_finalize(statement)
        return false
    }
}

// MARK: - DDL
extension DBManager {
    func createDB() {
        var db: OpaquePointer? = nil
        do {
            if let appGroupContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.gangyebab") {
                let filePath = appGroupContainerURL.appendingPathComponent("todo.sqlite")
                
                if sqlite3_open(filePath.path, &db) == SQLITE_OK {
                    print("Success create db Path")
                    self.db = db
                    return
                } else {
                    print("Failed to open database")
                }
            } else {
                print("Failed to get App Group container URL")
            }
        } catch {
            print("Error in createDB: \(error.localizedDescription)")
        }
        print("Error in createDB - sqlite3_open")
        self.db = nil
    }
    
    func createTodoTable() {
        let query = """
            CREATE TABLE IF NOT EXISTS todo (
                uuid TEXT PRIMARY KEY,
                title TEXT,
                importance INTEGER,
                isCompleted INTEGER,
                repeatType INTEGER,
                repeatId INTEGER,
                date TEXT,
                isDeleted INTEGER
            );
        """
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("create todo table success")
            } else {
                print("create todo table step fail")
            }
        } else {
            print("error: create todo table sqlite3 prepare fail")
        }
        sqlite3_finalize(statement)
    }
    
    func createRepeatTable() {
        let query = """
             CREATE TABLE IF NOT EXISTS rule (
                 repeatId INTEGER PRIMARY KEY AUTOINCREMENT,
                 title TEXT,
                 importance INTEGER,
                 repeatType INTEGER,
                 date TEXT,
                 isDeleted INTEGER
             );
         """
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("create repeat table success")
            } else {
                print("create repeat table step fail")
            }
        } else {
            print("error: create repeat table sqlite3 prepare fail")
        }
        sqlite3_finalize(statement)
    }
    
    
    func dropTodoTable() {
        let query = "DROP TABLE todo"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("delete todo table success")
            } else {
                print("delete todo table step fail")
            }
        } else {
            print("delete todo table prepare fail")
        }
    }
    
    func dropRepeatTable() {
        let query = "DROP TABLE rule"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("delete rule table success")
            } else {
                print("delete rule table step fail")
            }
        } else {
            print("delete rule table prepare fail")
        }
    }
    
    func resetDB() {
        dropTodoTable()
        dropRepeatTable()
    }
}

// MARK: - DML
extension DBManager {
    @discardableResult
    func insertTodoData(_ todoData: TodoModel) -> IsSuccess {
        let query = "INSERT INTO todo (uuid, title, importance, isCompleted, repeatType, repeatId, date, isDeleted) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            let uuidString = todoData.uuid.uuidString
            let title = todoData.title
            let importance = Int32(todoData.importance.rawValue)
            let isCompleted = todoData.isCompleted ? 1 : 0
            let repeatType = Int32(todoData.repeatType.rawValue)
            let repeatId = todoData.repeatId
            let date = todoData.date
            let isDeleted = todoData.isDeleted ? 1 : 0
            
            sqlite3_bind_text(statement, 1, (uuidString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, importance)
            sqlite3_bind_int(statement, 4, Int32(isCompleted))
            sqlite3_bind_int(statement, 5, repeatType)
            sqlite3_bind_int(statement, 6, Int32(repeatId))
            sqlite3_bind_text(statement, 7, (date as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 8, Int32(isDeleted))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Inserting todo data success")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to insert todo data")
                sqlite3_finalize(statement)
                return false
            }
        } else {
            print("Failed to prepare insert statement")
            sqlite3_finalize(statement)
            return false
        }
    }
    
    @discardableResult
    func insertRepeatData(_ repeatData: RepeatRuleModel) -> IsSuccess {
        let query = "INSERT INTO rule (title, importance, repeatType, date, isDeleted) VALUES (?, ?, ?, ?, ?);"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            let title = repeatData.title
            let importance = Int32(repeatData.importance.rawValue)
            let repeatType = Int32(repeatData.repeatType.rawValue)
            let date = repeatData.date
            let isDeleted = repeatData.isDeleted ? 1 : 0
            
            sqlite3_bind_text(statement, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(importance))
            sqlite3_bind_int(statement, 3, Int32(repeatType))
            sqlite3_bind_text(statement, 4, (date as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 5, Int32(isDeleted))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Inserting repeat data success")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to insert repeat data")
                sqlite3_finalize(statement)
                return false
            }
        } else {
            print("Failed to prepare insert statement")
            sqlite3_finalize(statement)
            return false
        }
    }
    
    func readTodoDatas(_ date: String) -> [TodoModel] {
        var todos: [TodoModel] = []
        let query = "SELECT * FROM todo WHERE date = ?;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (date as NSString).utf8String, -1, nil)
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let uuid = String(cString: sqlite3_column_text(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                let importance = Importance(rawValue: Int(sqlite3_column_int(statement, 2))) ?? .none
                let isCompleted = sqlite3_column_int(statement, 3) == 1 ? true : false
                let repeatType = RepeatType(rawValue: Int(sqlite3_column_int(statement, 4))) ?? .none
                let repeatId = Int(sqlite3_column_int(statement, 5))
                let todoDate = String(cString: sqlite3_column_text(statement, 6))
                let isDeleted =  sqlite3_column_int(statement, 7) == 1 ? true : false
                
                let todoData = TodoModel(
                    uuid: UUID(uuidString: uuid) ?? UUID(),
                    title: title,
                    importance: importance,
                    isCompleted: isCompleted,
                    repeatType: repeatType,
                    date: todoDate, 
                    repeatId: repeatId,
                    isDeleted: isDeleted
                )
                
                todos.append(todoData)
            }
        } else {
            print("Read Data prepare fail")
        }
        
        sqlite3_finalize(statement)
        return todos
    }
    
    func readTodoByUUID(uuid: UUID) -> TodoModel? {
        var todo: TodoModel?
        let query = "SELECT * FROM todo WHERE uuid = ?;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (uuid.uuidString as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let title = String(cString: sqlite3_column_text(statement, 1))
                let importance = Int(sqlite3_column_int(statement, 2))
                let isCompleted = sqlite3_column_int(statement, 3) == 1 ? true : false
                let repeatType = Int(sqlite3_column_int(statement, 4))
                let repeatId = Int(sqlite3_column_int(statement, 5))
                let date = String(cString: sqlite3_column_text(statement, 6))
                let isDeleted = sqlite3_column_int(statement, 7) == 1 ? true : false
                
                todo = TodoModel(
                    uuid: uuid,
                    title: title,
                    importance: Importance(rawValue: importance) ?? .low,
                    isCompleted: isCompleted,
                    repeatType: RepeatType(rawValue: repeatType) ?? .none,
                    date: date,
                    repeatId: repeatId,
                    isDeleted: isDeleted
                )
            } else {
                print("Todo with UUID \(uuid.uuidString) not found")
            }
        } else {
            print("Failed to prepare statement")
        }
        
        sqlite3_finalize(statement)
        return todo
    }
    
    func readRepeatData() -> [RepeatRuleModel] {
        var repeatRules: [RepeatRuleModel] = []
        let query = "SELECT * FROM rule"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let repeatId = Int(sqlite3_column_int(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                let importance = Int(sqlite3_column_int(statement, 2))
                let repeatType = Int(sqlite3_column_int(statement, 3))
                let date = String(cString: sqlite3_column_text(statement, 4))
                let isDeleted =  sqlite3_column_int(statement, 5) == 1 ? true : false
                
                let repeatRule = RepeatRuleModel(
                    repeatId: repeatId,
                    title: title,
                    importance: Importance(rawValue: importance) ?? .low,
                    repeatType: RepeatType(rawValue: repeatType) ?? .none,
                    date: date,
                    isDeleted: isDeleted
                )
                
                repeatRules.append(repeatRule)
            }
        } else {
            print("Read Data prepare fail")
        }
        
        sqlite3_finalize(statement)
        
        return repeatRules
    }
    
    func readRepeatRule(by repeatId: Int) -> RepeatRuleModel? {
        let query = "SELECT * FROM rule WHERE repeatId = ?"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(repeatId))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let repeatId = Int(sqlite3_column_int(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                let importance = Int(sqlite3_column_int(statement, 2))
                let repeatType = Int(sqlite3_column_int(statement, 3))
                let date = String(cString: sqlite3_column_text(statement, 4))
                let isDeleted = sqlite3_column_int(statement, 5) == 1 ? true : false
                
                let repeatRule = RepeatRuleModel(
                    repeatId: repeatId,
                    title: title,
                    importance: Importance(rawValue: importance) ?? .low,
                    repeatType: RepeatType(rawValue: repeatType) ?? .none,
                    date: date,
                    isDeleted: isDeleted
                )
                
                sqlite3_finalize(statement)
                return repeatRule
            }
        } else {
            print("Get Repeat Rule prepare fail")
        }
        
        sqlite3_finalize(statement)
        return nil
    }
    
    @discardableResult
    func deleteTodoData(_ uuid: UUID) -> IsSuccess {
        let query = "DELETE FROM todo WHERE uuid = ?;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            let uuidString = uuid.uuidString
            sqlite3_bind_text(statement, 1, (uuidString as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Delete todo data success")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Delete todo data step fail")
                sqlite3_finalize(statement)
                return false
            }
        } else {
            print("Delete todo data prepare fail")
            sqlite3_finalize(statement)
            return false
        }
    }

    @discardableResult
    func deleteRepeatData(_ repeatId: Int) -> IsSuccess {
        let query = "DELETE FROM rule WHERE repeatId = ?;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(repeatId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Delete repeat data success")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Delete repeat data step fail")
                sqlite3_finalize(statement)
                return false
            }
        } else {
            print("Delete repeat data prepare fail")
            sqlite3_finalize(statement)
            return false
        }
    }
    
    @discardableResult
    func updateTodoData(_ todo: TodoModel) -> IsSuccess {
        let query = "UPDATE todo SET title = ?, importance = ?, isCompleted = ?, repeatType = ?, repeatId = ?, date = ?, isDeleted = ? WHERE uuid = ?;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (todo.title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(todo.importance.rawValue))
            sqlite3_bind_int(statement, 3, todo.isCompleted ? 1 : 0)
            sqlite3_bind_int(statement, 4, Int32(todo.repeatType.rawValue))
            sqlite3_bind_int(statement, 5, Int32(todo.repeatId))
            sqlite3_bind_text(statement, 6, (todo.date as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 7, todo.isDeleted ? 1 : 0)
            sqlite3_bind_text(statement, 8, (todo.uuid.uuidString as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Success: Todo data updated")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Error: Todo data update failed")
                sqlite3_finalize(statement)
                return false
            }
        } else {
            print("Error: Prepare statement failed")
            sqlite3_finalize(statement)
            return false
        }
    }

    @discardableResult
    func updateRepeatData(_ repeatData: RepeatRuleModel) -> IsSuccess {
        let query = "UPDATE rule SET title = ?, importance = ?, repeatType = ?, date = ?, isDeleted = ? WHERE repeatId = ?;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (repeatData.title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(repeatData.importance.rawValue))
            sqlite3_bind_int(statement, 3, Int32(repeatData.repeatType.rawValue))
            sqlite3_bind_text(statement, 4, (repeatData.date as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 5, repeatData.isDeleted ? 1 : 0)
            sqlite3_bind_int(statement, 6, Int32(repeatData.repeatId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Success: Repeat data updated")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Error: Repeat data update failed")
                sqlite3_finalize(statement)
                return false
            }
        } else {
            print("Error: Prepare statement failed")
            sqlite3_finalize(statement)
            return false
        }
    }
    
    func countRules() -> Int {
        let query = "SELECT COUNT(*) FROM rule;"
        var statement: OpaquePointer? = nil
        var count = 0
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            } else {
                print("Failed to get count")
            }
        } else {
            print("Failed to prepare statement")
        }
        
        sqlite3_finalize(statement)
        return count
    }
}
