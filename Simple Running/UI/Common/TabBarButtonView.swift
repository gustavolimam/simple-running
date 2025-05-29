//
//  TabBarButtonView.swift
//  Simple Running
//
//  Created by Gustavo Monteiro on 16/05/25.
//

import SwiftUI

struct TabBarButtonView: View {
    let tabItem: TabItem
    @Binding var selectedTab: TabItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tabItem.systemImageName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(selectedTab == tabItem ? .accentColor : .secondary)
                Text(tabItem.label)
                    .font(.footnote)
                    .foregroundColor(selectedTab == tabItem ? .accentColor : .secondary)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                Group {
                    if selectedTab == tabItem {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.accentColor.opacity(0.15))
                    }
                }
            )
        }
    }
}

struct TabBarButtonView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(TabItem.today) { selection in
            HStack {
                TabBarButtonView(tabItem: .today, selectedTab: selection, action: { selection.wrappedValue = .today })
                TabBarButtonView(tabItem: .calendar, selectedTab: selection, action: { selection.wrappedValue = .calendar })
                TabBarButtonView(tabItem: .add, selectedTab: selection, action: { selection.wrappedValue = .add })
            }
            .padding()
            .background(Color.gray.opacity(0.2))
        }
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    var body: some View {
        content($value)
    }

    init(_ initialValue: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: initialValue)
        self.content = content
    }
}
