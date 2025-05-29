//
//  TabItem.swift
//  Simple Running
//
//  Created by Gustavo Monteiro on 16/05/25.
//

import SwiftUI

enum TabItem: Hashable, CaseIterable {
    case today
    case calendar

    var systemImageName: String {
        switch self {
        case .today:
            return "sun.max.fill"
        case .calendar:
            return "calendar"
        }
    }

    var label: String {
        switch self {
        case .today:
            return "Hoje"
        case .calendar:
            return "Calendário"
        }
    }
}
