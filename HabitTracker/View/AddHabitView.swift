//
//  AddHabitView.swift
//  HabitTracker
//
//  Created by Ivan Trajanovski on 24.04.23.
//

import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @Environment(\.self) var env
    
    var body: some View {
        NavigationView{
            VStack(spacing: 15){
                TextField("Title", text: $habitViewModel.title)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color("TFBG").opacity(0.4), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                
                // MARK: Habit color picker
                HStack(spacing: 0) {
                    ForEach(1...7, id: \.self){ index in
                        let color = "Card-\(index)"
                        Circle()
                            .fill(Color(color))
                            .frame(width: 30, height: 30)
                            .overlay(content: {
                                if color == habitViewModel.habitColor{
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                }
                            })
                            .onTapGesture {
                                withAnimation{
                                    habitViewModel.habitColor = color
                                }
                            }
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical)
                
                Divider()
                
                //MARK: Frequency Selection
                VStack(alignment: .leading, spacing: 6) {
                    Text("Frequency")
                        .font(.callout.bold())
                    let weekDays = Calendar.current.weekdaySymbols
                    HStack(spacing: 10) {
                        ForEach(weekDays, id: \.self) { day in
                            let index = habitViewModel.weekdays.firstIndex { value in
                                return value == day
                            } ?? -1
                            Text(day.prefix(2))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background{
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(index != -1 ? Color(habitViewModel.habitColor) : Color("TFBG").opacity(0.4))
                                }
                                .onTapGesture {
                                    withAnimation {
                                        if index != -1 {
                                            habitViewModel.weekdays.remove(at: index)
                                        } else {
                                            habitViewModel.weekdays.append(day)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.top, 15)
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                HStack{
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reminder")
                            .fontWeight(.semibold)
                        Text("Just notification")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Toggle(isOn: $habitViewModel.isReminderOn) {}
                        .labelsHidden()
                }
                .opacity(habitViewModel.notificationAccess ? 1 : 0)
                
                HStack(spacing: 12) {
                    Label {
                        Text(habitViewModel.reminderDate.formatted(date: .omitted, time: .shortened))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color("TFBG").opacity(0.4), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .onTapGesture {
                        withAnimation {
                            habitViewModel.showTimePicker.toggle()
                        }
                    }
                    
                    TextField("Reminder Text", text: $habitViewModel.reminderText)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color("TFBG").opacity(0.4), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    
                }
                .frame(height: habitViewModel.isReminderOn ? nil : 0)
                .opacity(habitViewModel.isReminderOn ? 1 : 0)
                .opacity(habitViewModel.notificationAccess ? 1 : 0)

            }
            .animation(.easeInOut, value: habitViewModel.isReminderOn)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle( habitViewModel.editHabit != nil ? "Edit Habit" : "Add Habit")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .tint(.white)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if habitViewModel.deleteHabit(context: env.managedObjectContext) {
                            env.dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    .opacity(habitViewModel.editHabit == nil ? 0 : 1)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        Task {
                            if await (habitViewModel.addHabit(context: env.managedObjectContext)) {
                                env.dismiss()
                            }
                        }
                    }
                    .tint(.white)
                    .disabled(!habitViewModel.doneStatus())
                    .opacity(habitViewModel.doneStatus() ? 1 : 0.6)
                }
            }
        }
        .overlay {
            if habitViewModel.showTimePicker{
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                habitViewModel.showTimePicker.toggle()
                            }
                        }
                    
                    DatePicker.init("", selection:
                                        $habitViewModel.reminderDate, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("TFBG"))
                    }
                                .padding()
                }
            }
        }
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView()
            .environmentObject(HabitViewModel())
            .preferredColorScheme(.dark)
    }
}
