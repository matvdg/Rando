//
//  ImportView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 31/05/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import HealthKit

struct ImportView: View {
    
    @State var url: String = ""
    @State var showFilePicker = false
    @Binding var showImportView: Bool
    @State var trailsToImport = [Trail]()
    @State private var showAlert = false
    @State private var isLoadingUrl = false
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
                    HStack(alignment: .center, spacing: 8) {
                        TextField("ImportFromURL", text: $url)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            if let url = URL(string: url), let _ = url.scheme {
                                isLoadingUrl = true
                                trailsToImport.insert(contentsOf: TrailManager.shared.loadTrails(from: [url]), at: 0)
                                isLoadingUrl = false
                            } else {
                                showAlert = true
                            }
                        } label: {
                            if isLoadingUrl {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            } else {
                                Image(systemName: "arrow.down.doc.fill")
                            }
                            
                        }
                        .buttonStyle(.borderedProminent)
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Error"), message: Text("UrlError"), dismissButton: .default(Text("OK")))
                        }
                        .disabled(isLoadingUrl)
                    }
                    Text("or")
                    HStack(alignment: .center, spacing: 8) {
                        Button {
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
                                Text("ImportFromFiles")
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoadingFiles)
                        Button {
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
                                Text("ImportFromFitness")
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("Error"), message: Text("WorkoutError"), dismissButton: .default(Text("OK")))
                            }
                            
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoadingFitness)
                        .isHidden(isHealthNotAvailable, remove: true)
                    }
                } // Top
                .padding()
                Divider()
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    Text("GPXtoImport").font(.headline)
                    Spacer()
                    ScrollView(.horizontal, showsIndicators: false) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(trailsToImport) { ImportGpxTileView(trailsToImport: $trailsToImport, trail: $0) }
                            }
                        }
                        .padding()
                    }
                    Spacer()
                    Button {
                        trailManager.save(trails: trailsToImport)
                        trailsToImport.removeAll()
                        showImportView = false
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("\("Add".localized) \(trailsToImport.count) GPX")
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                } // Bottom
                .isHidden(trailsToImport.isEmpty)
                
                
            }
            .navigationBarTitle(Text("ImportGPX"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showImportView = false
                Feedback.selected()
            }) {
                DismissButton()
            })
            .accentColor(.grgreen)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showFilePicker) {
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

struct ImportView_Previews: PreviewProvider {
    
    @State static var showImportView = false
    static var previews: some View {
        
        Group {
            ImportView(showImportView: $showImportView)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")
            ImportView(showImportView: $showImportView)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
        }
    }
}
