//
//  HabitViewModel.swift
//  HabitTracker
//
//  Created by Ivan Trajanovski on 24.04.23.
//

import SwiftUI
import CoreData

class HabitViewModel: ObservableObject {
    @Published var addNewHabit: Bool = false
    
    @Published var title: String = ""
    @Published var habitColor: String = "Card-1"
    @Published var weekdays: [String] = []
    @Published var isReminderOn: Bool = false
    @Published var reminderText: String = ""
    @Published var reminderDate: Date = Date()
}
