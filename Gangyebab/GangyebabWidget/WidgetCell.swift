//
//  WidgetCell.swift
//  Gangyebab
//
//  Created by 이동현 on 3/18/24.
//

import SwiftUI

struct WidgetCell: View {

    var content: String
    var importance: Importance

    var body: some View {
        ZStack {
            Button(action: {}, label: {
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                        .frame(maxWidth: 5, maxHeight: 15)
                        .background(Color(importance.color))
                    
                    Text("\(content)")
                        .padding(.leading, 5)
                        .lineLimit(1)
                    Spacer()
                }
            })
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .buttonStyle(.plain)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetCell(content: "sss", importance: .medium)
    }
}
