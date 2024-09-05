//
//  ImportView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 31/05/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import HealthKit

struct ImportView: View {
    
    @State var showFilePicker = false
    @Binding var showImportView: Bool
    @State var trailsToImport = [Trail]()
    @State private var showAlert = false
    @State private var isLoadingFiles = false
    @State private var isLoadingFitness = false
    @State var showWorkoutView: Bool = false
    @State var workouts: [HKWorkout] = []
    
    private let trailManager = TrailManager.shared
    private let workoutManager = WorkoutManager.shared
    private let isHealthNotAvailable = !WorkoutManager.shared.isAvailable
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .center, spacing: 8) {
                    Button {
                        if let clipboardString = UIPasteboard.general.string, let url = URL(string: clipboardString), let _ = url.scheme {
                            trailsToImport.insert(contentsOf: TrailManager.shared.loadTrails(from: [url]), at: 0)
                        } else {
                            showAlert = true
                        }
                    } label: {
                        Label("importFromPasteboard", systemImage: "clipboard")
                        .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("error"), message: Text("urlError"), dismissButton: .default(Text("ok")))
                    }
                    Text("or")
                    HStack(alignment: .center, spacing: 8) {
                        Button {
                            Feedback.selected()
                            isLoadingFiles = true
                            showFilePicker = true
                        } label: {
                            HStack(spacing: 8) {
                                if isLoadingFiles {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                } else {
                                    Image(systemName: "folder.fill")
                                }
                                Text("importFromFiles")
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoadingFiles)
                        Button {
                            Feedback.selected()
                            isLoadingFitness = true
                            Task {
                                do {
                                    workouts = try await workoutManager.getWorkouts()
                                    showWorkoutView = true
                                } catch {
                                    print(error)
                                    showAlert = true
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if isLoadingFitness {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                } else {
                                    Image(systemName: "figure.hiking")
                                }
                                Text("importFromFitness")
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("error"), message: Text("workoutError"), dismissButton: .default(Text("ok")))
                            }
                            
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoadingFitness)
                        .isHidden(isHealthNotAvailable, remove: true)
                    }
                } // Top
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                Divider()
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    Text("gpxToImport").font(.headline)
                    Spacer()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(trailsToImport) { ImportGpxTileView(trailsToImport: $trailsToImport, trail: $0) }
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                    Button {
                        Feedback.selected()
                        trailManager.save(trails: trailsToImport)
                        trailsToImport.removeAll()
                        showImportView = false
                    } label: {
                        Label("\("add".localized) \(trailsToImport.count) GPX", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                } // Bottom
                .isHidden(trailsToImport.isEmpty)
            }
            .navigationBarTitle(Text("importGPX"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showImportView = false
                Feedback.selected()
            }) {
                DismissButton()
            })
            .accentColor(.grblue)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showFilePicker, onDismiss: {
            isLoadingFiles = false
        }) {
            DocumentView {
                trailsToImport.insert(contentsOf: trailManager.loadTrails(from: $0), at: 0)
                isLoadingFiles = false
            }
        }
        
        .sheet(isPresented: $showWorkoutView, onDismiss: {
            isLoadingFitness = false
        }) {
            WorkoutView(showWorkoutView: $showWorkoutView, workouts: $workouts, trailsToImport: $trailsToImport)
        }
        
    }
}

#Preview {
    ImportView(showImportView: .constant(true))
}
