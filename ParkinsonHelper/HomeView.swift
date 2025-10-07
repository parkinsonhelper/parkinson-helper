//
//  HomeView.swift
//  ParkinsonHelper
//
//  Created by Chan Jung on 9/25/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var scheduleManager: ScheduleManager
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    HeaderView()
                    ScheduleView(events: scheduleManager.upcomingEvents)
                    if #available(iOS 16.0, *) {
                        BloodPressureView(context: viewContext)
                    }
                }
                .padding(.bottom, 100)
            }
        }
        
    }
}


