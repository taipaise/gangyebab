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
    
    var db: OpaquePointer?
    var path = "todo.sqlite"
    
    private init() {
        self.db = createDB()
    }
}

// MARK: - DDL
extension DBManager {
    func createDB() -> OpaquePointer? {
        var db: OpaquePointer? = nil
        do {
            let filePath = try FileManager.default.url(
                for: .documentDirectory, in: .userDomainMask,
                appropriateFor: nil,
                create: false
            ).appendingPathComponent(path)
            
            if sqlite3_open(filePath.path, &db) == SQLITE_OK {
                print("Success create db Path")
                return db
            }
        }
        catch {
            print("error in createDB")
        }
        print("error in createDB - sqlite3_open")
        return nil
    }
    
    func createTodoTable() {
        let query = """
            CREATE TABLE IF NOT EXISTS todo (
                uuid TEXT PRIMARY KEY,
                title TEXT,
                importance INTEGER,
                isCompleted INTEGER,
                repeatType INTEGER,
                date TEXT
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
                 date TEXT
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
        let query = "DROP TABLE repeat"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("delete repeat table success")
            } else {
                print("delete repeat table step fail")
            }
        } else {
            print("delete repeat table prepare fail")
        }
    }
}

// MARK: - DML
extension DBManager {
    func insertTodoData(_ todoData: TodoModel) {
        let query = "INSERT INTO todo (uuid, title, importance, isCompleted, repeatType, repeatId, date) VALUES (?, ?, ?, ?, ?, ?, ?);"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            let uuidString = todoData.uuid.uuidString
            let title = todoData.title
            let importance = Int32(todoData.importance.rawValue)
            let isCompleted = todoData.isCompleted ? 1 : 0
            let repeatType = Int32(todoData.repeatType.rawValue)
            let repeatId = todoData.repeatId ?? -1
            let date = todoData.date
            
            sqlite3_bind_text(statement, 1, (uuidString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, importance)
            sqlite3_bind_int(statement, 4, Int32(isCompleted))
            sqlite3_bind_int(statement, 5, repeatType)
            sqlite3_bind_int(statement, 6, Int32(repeatId))
            sqlite3_bind_text(statement, 7, (date as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Inserting todo data success")
            } else {
                print("Failed to insert todo data")
            }
        } else {
            print("Failed to prepare insert statement")
        }
        
        sqlite3_finalize(statement)
    }
    
    func insertRepeatData(_ repeatData: RepeatRuleModel) {
        let query = "INSERT INTO rule (title, importance, repeatType, date) VALUES (?, ?, ?, ?);"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (repeatData.title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(repeatData.importance.rawValue))
            sqlite3_bind_int(statement, 3, Int32(repeatData.repeatType.rawValue))
            sqlite3_bind_text(statement, 4, (repeatData.date as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Inserting repeat data success")
            } else {
                print("Failed to insert repeat data")
            }
        } else {
            print("Failed to prepare insert statement")
        }
        
        sqlite3_finalize(statement)
    }
    
    func readTodoData(_ date: String) -> [TodoModel] {
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
                
                let todoData = TodoModel(
                    uuid: UUID(uuidString: uuid) ?? UUID(),
                    title: title,
                    importance: importance,
                    isCompleted: isCompleted,
                    repeatType: repeatType,
                    date: todoDate, 
                    repeatId: repeatId == -1 ? nil : repeatId
                )
                
                todos.append(todoData)
            }
        } else {
            print("Read Data prepare fail")
        }
        
        sqlite3_finalize(statement)
        
        return todos
    }
    
    func readRepeatData() -> [RepeatRuleModel] {
        var repeatRules: [RepeatRuleModel] = []
        let query = "SELECT * FROM repeat"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let repeatId = Int(sqlite3_column_int(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                let importance = Int(sqlite3_column_int(statement, 2))
                let repeatType = Int(sqlite3_column_int(statement, 3))
                let date = String(cString: sqlite3_column_text(statement, 4))
                
                let repeatRule = RepeatRuleModel(
                    repeatId: repeatId,
                    title: title,
                    importance: Importance(rawValue: importance) ?? .low,
                    repeatType: RepeatType(rawValue: repeatType) ?? .none,
                    date: date
                )
                
                repeatRules.append(repeatRule)
            }
        } else {
            print("Read Data prepare fail")
        }
        
        sqlite3_finalize(statement)
        
        return repeatRules
    }
    
    func deleteTodoData(_ uuid: UUID) {
        let query = "DELETE FROM todo WHERE uuid = ?;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            let uuidString = uuid.uuidString
            sqlite3_bind_text(statement, 1, (uuidString as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Delete todo data success")
            } else {
                print("Delete todo data step fail")
            }
        } else {
            print("Delete todo data prepare fail")
        }
        
        sqlite3_finalize(statement)
    }

    func deleteRepeatData(_ repeatId: Int) {
        let query = "DELETE FROM repeat WHERE repeatId = ?;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(repeatId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Delete repeat data success")
            } else {
                print("Delete repeat data step fail")
            }
        } else {
            print("Delete repeat data prepare fail")
        }
        
        sqlite3_finalize(statement)
    }
    
    func updateTodoData(_ todo: TodoModel) {
        let query = "UPDATE todo SET title = ?, importance = ?, isCompleted = ?, repeatType = ?, repeatId = ?, date = ? WHERE uuid = ?;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (todo.title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(todo.importance.rawValue))
            sqlite3_bind_int(statement, 3, todo.isCompleted ? 1 : 0)
            sqlite3_bind_int(statement, 4, Int32(todo.repeatType.rawValue))
            sqlite3_bind_int(statement, 5, Int32(todo.repeatId ?? -1))
            sqlite3_bind_text(statement, 6, (todo.date as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 7, (todo.uuid.uuidString as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Success: Todo data updated")
            } else {
                print("Error: Todo data update failed")
            }
        } else {
            print("Error: Prepare statement failed")
        }
        
        sqlite3_finalize(statement)
    }

    func updateRepeatData(_ repeatData: RepeatRuleModel) {
        let query = "UPDATE repeat SET title = ?, importance = ?, repeatType = ?, date = ? WHERE repeatId = ?;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (repeatData.title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(repeatData.importance.rawValue))
            sqlite3_bind_int(statement, 3, Int32(repeatData.repeatType.rawValue))
            sqlite3_bind_text(statement, 4, (repeatData.date as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 5, Int32(repeatData.repeatId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Success: Repeat data updated")
            } else {
                print("Error: Repeat data update failed")
            }
        } else {
            print("Error: Prepare statement failed")
        }
        
        sqlite3_finalize(statement)
    }
}
