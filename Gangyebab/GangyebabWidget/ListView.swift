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
    
    var body: some View {
        let items = todos.prefix(maxCount)

        VStack {
                ForEach(0..<maxCount) { index in
                    if index < items.count {
                        let item = items[index]
                        WidgetCell(content: item.title, importance: item.importance)
                    } else {
                        Spacer()
                    }
                }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(maxCount: 5, todos: [])
    }
}

