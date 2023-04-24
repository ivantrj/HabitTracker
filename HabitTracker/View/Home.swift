//
//  Home.swift
//  HabitTracker
//
//  Created by Ivan Trajanovski on 20.04.23.
//

import SwiftUI

struct Home: View {
    
    @FetchRequest(entity: Habit.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Habit.dateAdded, ascending: false)], predicate: nil, animation: .easeInOut)
    
    var habits: FetchedResults<Habit>
    
    @StateObject var habitViewModel: HabitViewModel = .init()
    
    var body: some View {
        VStack(spacing: 0){
            Text("Habits")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
            }
            
            
            ScrollView(habits.isEmpty ? .init() : .vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    // MARK: Add habits
                    Button {
                        habitViewModel.addNewHabit.toggle()
                    } label: {
                        Label {
                            Text("New habit")
                        } icon: {
                            Image(systemName: "plus.circle")
                        }
                        .font(.callout.bold())
                        .foregroundColor(.white)
                    }
                }
                .padding(.top, 15)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .padding(.vertical)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .sheet(isPresented: $habitViewModel.addNewHabit) {
            
        } content: {
            
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
