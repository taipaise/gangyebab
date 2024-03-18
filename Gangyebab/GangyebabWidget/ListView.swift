//
//  ListView.swift
//  Gangyebab
//
//  Created by 이동현 on 3/18/24.
//

import SwiftUI

struct ListView: View {
    var maxCount: Int
    var todos: [TodoModel]
    var onTap: (TodoModel) -> Void
    
    var body: some View {
        let items = todos.prefix(maxCount)

        VStack {
                ForEach(0..<maxCount) { index in
                    if index < items.count {
                        let item = items[index]
                        WidgetCell(todo: item, onTap: onTap)
                    } else {
                        Spacer()
                    }
                }
        }
    }
}

