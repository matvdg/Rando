//
//  FilterView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

enum GRFilter: String, CaseIterable {
    case gr, hr, ghr, notghr, all
    var localized: String { rawValue.localized }
}

enum DifficultyFilter: String, CaseIterable {
    case beginner, easy, medium, hard, extreme, all
    var localized: String { rawValue.localized }
}

struct FilterView: View {
    
    @Binding var onlyDisplayed: Bool
    @Binding var onlyFavs: Bool
    @Binding var onlyLoops: Bool
    @Binding var grFilter: GRFilter
    @Binding var difficultyFilter: DifficultyFilter
    @Binding var department: String
    @Binding var isSortDisplayed: Bool
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .center, spacing: 20.0) {
                
                Toggle(isOn: self.$onlyDisplayed) {
                    Text("displayed")
                }
                .onTapGesture {
                    self.onlyDisplayed.toggle()
                }
                
                Toggle(isOn: self.$onlyFavs) {
                    Text("favs")
                }
                .onTapGesture {
                    self.onlyFavs.toggle()
                }
                
                Toggle(isOn: self.$onlyLoops) {
                    Text("loops")
                }
                .onTapGesture {
                    self.onlyLoops.toggle()
                }
                
                Divider()
                
                HStack {
                    Text("ghr")
                        .font(.headline)
                    Spacer()
                    Picker(selection: $grFilter, label: Text("")) {
                        ForEach(GRFilter.allCases, id: \.self) { grFilter in
                            Text(LocalizedStringKey(grFilter.rawValue))
                        }
                    }
                    .onChange(of: grFilter) { oldValue, newValue in
                        Feedback.selected()
                    }
                    .pickerStyle(.menu)
                }
                
                HStack {
                    Text("departments")
                        .font(.headline)
                    Spacer()
                    Picker(selection: $department, label: Text("")) {
                        
                        ForEach(TrailManager.shared.departments, id: \.self) { text in
                            Text(LocalizedStringKey(text))
                        }
                    }
                    .onChange(of: department) { oldValue, newValue in
                        Feedback.selected()
                    }
                    .pickerStyle(.menu)
                }
                
                HStack {
                    Text("difficulty")
                        .font(.headline)
                    Spacer()
                    Picker(selection: $difficultyFilter, label: Text("")) {
                        
                        ForEach(DifficultyFilter.allCases, id: \.self) { difficultyFilter in
                            Text(LocalizedStringKey(difficultyFilter.rawValue))
                        }
                    }
                    .onChange(of: difficultyFilter) { oldValue, newValue in
                        Feedback.selected()
                    }
                    .pickerStyle(.menu)
                }
                            
            }
            .padding()
            .navigationBarTitle("filter", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                isSortDisplayed = false
                Feedback.selected()
            }) {
                DismissButton()
            })
        }
        .tint(.tintColorTabBar)
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(maxWidth: 500)
        .frame(height: 500, alignment: .top)
        .cornerRadius(8)
        .shadow(radius: 10)
        
    }
    
}

// MARK: Preview
#Preview {
    FilterView(onlyDisplayed: .constant(false), onlyFavs: .constant(false), onlyLoops: .constant(false), grFilter: .constant(.ghr), difficultyFilter: .constant(.hard), department: .constant("Ariège"), isSortDisplayed: .constant(true))
}
