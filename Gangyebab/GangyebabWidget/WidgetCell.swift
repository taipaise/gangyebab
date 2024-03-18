//
//  WidgetCell.swift
//  Gangyebab
//
//  Created by 이동현 on 3/18/24.
//

import SwiftUI

struct WidgetCell: View {
    var todo: TodoModel
    var onTap: (TodoModel) -> Void

    var body: some View {
        ZStack {
            Button(action: {
                onTap(todo)
            }, label: {
                if !todo.isCompleted {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                            .frame(maxWidth: 5, maxHeight: 15)
                            .background(Color(todo.importance.color))
                        
                        Text("\(todo.title)")
                            .font(Font.custom("SOYO-Maple-Regular", size: 15))
                            .padding(.leading, 5)
                            .lineLimit(1)
                        Spacer()
                    }
                } else {
                    HStack(alignment: .center, spacing: 0) {    
                        Text("\(todo.title)")
                            .font(Font.custom("SOYO-Maple-Regular", size: 15))
                            .strikethrough(true)
                            .padding(.leading, 5)
                            .lineLimit(1)
                        Spacer()
                    }
                }
            })
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .buttonStyle(.plain)
        }
    }
}
