//
//  TabBarView.swift
//  Simple Running
//
//  Created by Gustavo Monteiro on 02/06/25.
//

import SwiftUI

enum Tab: Int, Identifiable, CaseIterable, Comparable {
    static func < (lhs: Tab, rhs: Tab) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case today, calendar, settings
    
    internal var id: Int { rawValue }
    
    var icon: String {
        switch self {
        case .today:
            return "figure.run"
        case .calendar:
            return "calendar"
        case .settings:
            return "gearshape.fill"
        }
    }
    
    var title: String {
        switch self {
        case .today:
            return "Today"
        case .calendar:
            return "Calendar"
        case .settings:
            return "Settings"
        }
    }
    
    var color: Color {
        switch self {
        case .today:
            return .accentColor
        case .calendar:
            return .accentColor        
        case .settings:
            return .accentColor
        }
    }
}
