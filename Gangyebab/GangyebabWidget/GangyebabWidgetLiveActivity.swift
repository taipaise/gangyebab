//
//  GangyebabWidgetLiveActivity.swift
//  GangyebabWidget
//
//  Created by 이동현 on 3/18/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GangyebabWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GangyebabWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GangyebabWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension GangyebabWidgetAttributes {
    fileprivate static var preview: GangyebabWidgetAttributes {
        GangyebabWidgetAttributes(name: "World")
    }
}

extension GangyebabWidgetAttributes.ContentState {
    fileprivate static var smiley: GangyebabWidgetAttributes.ContentState {
        GangyebabWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: GangyebabWidgetAttributes.ContentState {
         GangyebabWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GangyebabWidgetAttributes.preview) {
   GangyebabWidgetLiveActivity()
} contentStates: {
    GangyebabWidgetAttributes.ContentState.smiley
    GangyebabWidgetAttributes.ContentState.starEyes
}
