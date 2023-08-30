//
//  WorkoutView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 01/06/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import HealthKit

struct WorkoutView: View {
    
    enum Sorting: String, CaseIterable, Equatable {
        case date, distance, duration
        var localized: String { self.rawValue }
    }
    
    @Binding var showWorkoutView: Bool
    @Binding var workouts: [HKWorkout]
    @State var workoutActivity: WorkoutActivity = .all
    @State var sorting: Sorting = .date
    @State var minDistance: Double = 0
    @Binding var trailsToImport: [Trail]
    
    private let workoutManager = WorkoutManager.shared
    
    private var sortedWorkouts: [HKWorkout] {
        // Sort
        var sortedWorkouts = workouts.sorted {
            switch sorting {
            case .date : return $0.startDate > $1.startDate
            case .distance: return $0.totalDistance?.doubleValue(for: .meter()) ?? 0 > $1.totalDistance?.doubleValue(for: .meter()) ?? 0
            case .duration: return $0.duration > $1.duration
            }
        }
        // Filter by activity if not .all
        if let activity = workoutActivity.activity {
            sortedWorkouts = sortedWorkouts.filter { $0.workoutActivityType == activity }
        }
        // Filter by minDistance
        sortedWorkouts = sortedWorkouts.filter { $0.totalDistance?.doubleValue(for: .meter()) ?? 0 >= minDistance }
        // Remove non importable workouts (without distance)
        sortedWorkouts = sortedWorkouts.filter { $0.totalDistance != nil }
        return sortedWorkouts
    }
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .leading, spacing: 8) {
                Picker(selection: $sorting, label: Text("")) {
                    ForEach(Sorting.allCases, id: \.self) { sort in
                        Text(LocalizedStringKey(sort.rawValue))
                    }
                }.pickerStyle(SegmentedPickerStyle())
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                HStack(alignment: .center, spacing: 8) {
                    
                    Slider(value: $minDistance, in: 0...20000, onEditingChanged: { _ in
                        Feedback.selected()
                    })
                    .tint(.tintColorTabBar)
                    Text("\("MoreThan".localized) \(minDistance.toString)")
                }
                .padding()
                
                List {
                    ForEach(sortedWorkouts, id: \.self) { workout in
                        WorkoutRow(showHealthView: $showWorkoutView, trailsToImport: $trailsToImport, workout: workout)
                    }
                }
            }
            .navigationBarTitle("ImportFromWorkout", displayMode: .inline)
            .navigationBarItems(leading: Picker(selection: $workoutActivity, label: Text("")) {
                ForEach(WorkoutActivity.allCases, id: \.self) { activity in
                    HStack(alignment: .center, spacing: 8) {
                        Text(LocalizedStringKey(activity.rawValue))
                        activity.icon
                    }
                }
            }.tint(.tintColorTabBar)
            , trailing: Button(action: {
                showWorkoutView = false
                Feedback.selected()
            }) {
                DismissButton()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
}

struct HealthView_Previews: PreviewProvider {
    
    @State static var showHealthView: Bool = false
    @State static var workouts: [HKWorkout] = []
    @State static var trailsToImport = [Trail]()
    
    static var previews: some View {
        WorkoutView(showWorkoutView: $showHealthView, workouts: $workouts, trailsToImport: $trailsToImport)
    }
}
