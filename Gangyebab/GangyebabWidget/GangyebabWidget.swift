//
//  GangyebabWidget.swift
//  GangyebabWidget
//
//  Created by 이동현 on 3/17/24.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct MyWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    @ObservedObject var viewModel = WidgetViewModel()
    var entry: Provider.Entry
    
    @ViewBuilder
    var body: some View {
        if #available(iOSApplicationExtension 17.0, *) {
            ZStack {
                Color(.background1)
                switch self.family {
                case .systemSmall:
                    VStack {
                        HStack {
                            Image(systemName: "circle")
                            Text("3월 5일")
                            Spacer()
                        }
                        ListView(maxCount: 3, todos: [])
                    }
                case .systemMedium:
                    HStack {
                        VStack {
                            HStack {
                                Image(systemName: "circle")
                                Text("3/5")
                                Spacer()
                            }
                            ListView(maxCount: 3, todos: Array(viewModel.todos.prefix(3)))
                        }
                        ListView(maxCount: 4, todos: Array(viewModel.todos.prefix(4)))
                    }
                case .systemLarge:
                    HStack {
                        VStack {
                            HStack {
                                Image(systemName: "circle")
                                Text("3월 5일")
                                Spacer()
                            }
                            ListView(maxCount: 9, todos: [])
                        }
                        ListView(maxCount: 10, todos: [])
                    }
                default:
                    Text("")
                }
            }
            .padding(10)
            .containerBackground(for: .widget) {}
            
        } else {
            ZStack {
                Color(.background1)
                //                switch self.family {
                //                case .systemSmall:
                //                    ListView()
                //                case .systemMedium:
                //                    ListView()
                //                case .systemLarge:
                //                    ListView()
                //                default:
                //                    Text("")
                //                }
            }
            .padding(10)
        }
        
    }
    
    func maxItemCount() -> Int {
        switch self.family {
        case .systemSmall:
            return 5
        case .systemMedium:
            return 10
        case .systemLarge:
            return 22
        default:
            return 0
        }
    }
}

@main
struct GangyebabWidget: Widget {
  let kind: String = "GangyebabWidget"

  var body: some WidgetConfiguration {
    IntentConfiguration(
      kind: kind,
      intent: ConfigurationIntent.self,
      provider: Provider()
    ) { entry in
        MyWidgetEntryView(entry: entry).background(Color(.background1))
    }
    .contentMarginsDisabled()
    .configurationDisplayName("간계밥")
    .description("위젯으로 간편하게 한 일을 체크해보세요!")
  }
}

struct MyWidget_Previews: PreviewProvider {
  static var previews: some View {
    MyWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}
