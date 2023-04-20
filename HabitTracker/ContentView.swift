//
//  ContentView.swift
//  HabitTracker
//
//  Created by Ivan Trajanovski on 20.04.23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home()
            .preferredColorScheme(.dark)
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
