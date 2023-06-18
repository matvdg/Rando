//
//  WorkoutRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 06/06/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import HealthKit
import SwiftUI

struct WorkoutRow: View {
    
    @State var showMap = false
    @Binding var showHealthView: Bool
    @State var selectedLayer: Layer = .standard
    @State var locations: [Location] = []
    @Binding var trailsToImport: [Trail]
    @State var isLoading = false
    @State var isLoadingMap = false
    
    var workout: HKWorkout
    private let workoutManager = WorkoutManager.shared
    private var name: String {
        WorkoutActivity.activity(from: workout.workoutActivityType).localized + " · " + workout.startDate.toString
    }
    private var description: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let date = formatter.string(from: Date())
        return name + " · \("Imported".localized) \(date)"
    }
    private var distance: String {
        workout.totalDistance?.doubleValue(for: .meter()).toString ?? "_"
    }
    private var duration: String {
        workout.duration.toDurationString
    }
    
    var body: some View {
        
        HStack(spacing: 16) {
            
            Group {
                switch workout.workoutActivityType {
                case .hiking:
                    Image(systemName: "figure.hiking").resizable().frame(width: 20, height: 30, alignment: .center)
                case .walking:
                    Image(systemName: "figure.walk").resizable().frame(width: 20, height: 30, alignment: .center)
                case .running:
                    Image(systemName: "figure.run").resizable().frame(width: 20, height: 30, alignment: .center)
                case .cycling:
                    Image(systemName: "figure.outdoor.cycle").resizable().frame(width: 30, height: 25, alignment: .center)
                default:
                    Image(systemName: "figure.climbing").resizable().frame(width: 20, height: 30, alignment: .center)
                }
            }
            .foregroundColor(.tintColorTabBar)
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text(workout.startDate.toString).fontWeight(.bold)
                HStack(alignment: .center, spacing: 8) {
                    if distance != "_" {
                        Text(distance)
                        Text("·")
                    }
                    Text(duration)
                }
                .foregroundColor(.gray)
            }
            
            Spacer()
            HStack(alignment: .center, spacing: 8) {
                Button {
                    Feedback.selected()
                    Task {
                        do {
                            isLoadingMap = true
                            locations = try await workoutManager.getLocations(for: workout)
                            guard !locations.isEmpty else { return }
                            showMap = true
                            isLoadingMap = false
                        } catch {
                            print(error)
                            isLoadingMap = false
                        }
                    }
                } label: {
                    if isLoadingMap {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    } else {
                        Image(systemName: "map.fill")
                    }
                }
                .disabled(isLoadingMap)
                .buttonStyle(.borderedProminent)
                .tint(.grblue)
                Button {
                    Feedback.selected()
                    if locations.isEmpty {
                        Task {
                            do {
                                isLoading = true
                                locations = try await workoutManager.getLocations(for: workout)
                                trailsToImport.insert(Trail(gpx: Gpx(name: name, description: description, locations: locations, date: workout.startDate)), at: 0)
                                showHealthView = false
                                isLoading = false
                            } catch {
                                print(error)
                                isLoading = false
                            }
                        }
                    } else {
                        trailsToImport.insert(Trail(gpx: Gpx(name: name, description: description, locations: locations, date: workout.startDate)), at: 0)
                        showHealthView = false
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    } else {
                        Image(systemName: "arrow.down.doc.fill")
                    }
                }
                .disabled(isLoading)
                .buttonStyle(.borderedProminent)
                .tint(.grblue)
                
            }
            
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        .frame(height: 80.0)
        .sheet(isPresented: $showMap) {
            NavigationView {
                MapView(coordinates: $locations)
                    .navigationBarTitle(name, displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        trailsToImport.insert(Trail(gpx: Gpx(name: name, description: description, locations: locations, date: workout.startDate)), at: 0)
                        showHealthView = false
                        Feedback.selected()
                    }) {
                        Image(systemName: "arrow.down.doc.fill")
                            .foregroundColor(.tintColorTabBar)
                    }, trailing: Button(action: {
                        showMap = false
                        Feedback.selected()
                    }) {
                        DismissButton()
                    })
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
}

// MARK: Previews
struct WorkoutRow_Previews: PreviewProvider {
    
    static let workout: HKWorkout = HKWorkout(activityType: .hiking, start: Date(), end: Date())
    @State static var trailsToImport = [Trail]()
    @State static var showHealthView: Bool = false
    
    static var previews: some View {
        
        WorkoutRow(showHealthView: $showHealthView, trailsToImport: $trailsToImport, workout: workout)
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 320, height: 80))
        
    }
}
