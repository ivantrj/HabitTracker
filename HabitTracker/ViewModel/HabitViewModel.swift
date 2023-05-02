//
//  HabitViewModel.swift
//  HabitTracker
//
//  Created by Ivan Trajanovski on 24.04.23.
//

import SwiftUI
import CoreData
import UserNotifications

class HabitViewModel: ObservableObject {
    @Published var addNewHabit: Bool = false
    
    @Published var title: String = ""
    @Published var habitColor: String = "Card-1"
    @Published var weekdays: [String] = []
    @Published var isReminderOn: Bool = false
    @Published var reminderText: String = ""
    @Published var reminderDate: Date = Date()
    
    
    //mark: reminder time picker
    @Published var showTimePicker: Bool = false
    
    @Published var editHabit: Habit?
    
    @Published var notificationAccess: Bool = false
    
    init() {
        requestNotificationAccess()
    }
    
    func requestNotificationAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { status, _ in
            DispatchQueue.main.async {
                self.notificationAccess = status
            }
        }
    }
    
    //MARK: Add habit to db
    func addHabit(context: NSManagedObjectContext) async -> Bool {
        //MARK: Editing Data
        var habit: Habit!
        if let editHabit = editHabit {
            habit = editHabit
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editHabit.notificationIDs ?? [])
        } else {
            habit = Habit(context: context)
        }
        
        habit.title = title
        habit.color = habitColor
        habit.weekDays = weekdays
        habit.isReminderOn = isReminderOn
        habit.reminderText = reminderText
        habit.notificationDate = reminderDate
        habit.notificationIDs = []
        
        if isReminderOn {
            //MARK: Scheduling notifications
            if let ids = try? await scheduleNotification() {
                habit.notificationIDs = ids
                
                if let _ = try? context.save() {
                    return true
                }
            }
        } else {
            // MARK: Adding Data
            if let _ = try? context.save() {
                return true
            }
        }
        return false
    }
    
    //MARK: Adding notifications
    func scheduleNotification() async throws -> [String] {
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.subtitle = reminderText
        content.sound = UNNotificationSound.default
        
        var notificationsIDs: [String] = []
        let calendar = Calendar.current
        let weekdaySymbols: [String] = calendar.weekdaySymbols
        
        
        for weekday in weekdays {
            let id = UUID().uuidString
            let hour = calendar.component(.hour, from: reminderDate)
            let min = calendar.component(.minute, from: reminderDate)
            let day = weekdaySymbols.firstIndex { currentDay in
                return currentDay == weekday
            } ?? -1
            
            if day != -1 {
                var components = DateComponents()
                components.hour = hour
                components.minute = min
                components.weekday = day + 1
                
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                
                try await UNUserNotificationCenter.current().add(request)
                
                notificationsIDs.append(id)
            }
            
        }
        return notificationsIDs
    }
    
    func resetData() {
        title = ""
        habitColor = "Card-1"
        weekdays = []
        isReminderOn = false
        reminderDate = Date()
        reminderText = ""
    }
    
    func deleteHabit(context: NSManagedObjectContext) -> Bool {
        if let editHabit = editHabit {
            if editHabit.isReminderOn {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editHabit.notificationIDs ?? [])
            }
            context.delete(editHabit)
            if let _ = try? context.save() {
                return true
            }
        }
        return false
    }
    
    func restoreEditData() {
        if let editHabit = editHabit {
            title = editHabit.title ?? ""
            habitColor = editHabit.color ?? "Card-1"
            weekdays = editHabit.weekDays ?? []
            isReminderOn = editHabit.isReminderOn
            reminderDate = editHabit.notificationDate ?? Date()
            reminderText = editHabit.reminderText ?? ""
        }
    }
    
    // MARK: Done button status
    func doneStatus() -> Bool {
        let reminderStatus = isReminderOn ? reminderText == "" : false
        
        if title == "" || weekdays.isEmpty || reminderStatus {
            return false
        }
        return true
    }
}
