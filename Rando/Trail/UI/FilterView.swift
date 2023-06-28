//
//  FilterView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

enum Gr10Filter: String, CaseIterable {
    case gr10, notgr10, all
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
    @Binding var gr10Filter: Gr10Filter
    @Binding var difficultyFilter: DifficultyFilter
    @Binding var department: String
    @Binding var isSortDisplayed: Bool
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .center, spacing: 20.0) {
                
                Toggle(isOn: self.$onlyDisplayed) {
                    Text("Displayed")
                }
                .onTapGesture {
                    self.onlyDisplayed.toggle()
                }
                
                Toggle(isOn: self.$onlyFavs) {
                    Text("Favs")
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
                    Text("gr10")
                        .font(.headline)
                    Spacer()
                    Picker(selection: $gr10Filter, label: Text("")) {
                        ForEach(Gr10Filter.allCases, id: \.self) { gr10Filter in
                            Text(LocalizedStringKey(gr10Filter.rawValue))
                        }
                    }
                    .onChange(of: gr10Filter, perform: { newValue in
                        Feedback.selected()
                    })
                    .pickerStyle(.menu)
                }
                
                HStack {
                    Text("Departments")
                        .font(.headline)
                    Spacer()
                    Picker(selection: $department, label: Text("")) {
                        
                        ForEach(TrailManager.shared.departments, id: \.self) { text in
                            Text(LocalizedStringKey(text))
                        }
                    }
                    .onChange(of: department, perform: { newValue in
                        Feedback.selected()
                    })
                    .pickerStyle(.menu)
                }
                
                HStack {
                    Text("Difficulty")
                        .font(.headline)
                    Spacer()
                    Picker(selection: $difficultyFilter, label: Text("")) {
                        
                        ForEach(DifficultyFilter.allCases, id: \.self) { difficultyFilter in
                            Text(LocalizedStringKey(difficultyFilter.rawValue))
                        }
                    }
                    .onChange(of: difficultyFilter, perform: { newValue in
                        Feedback.selected()
                    })
                    .pickerStyle(.menu)
                }
                            
            }
            .padding()
            .navigationBarTitle("Filter", displayMode: .inline)
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
        .frame(height: 400, alignment: .top)
        .cornerRadius(8)
        .shadow(radius: 10)
        
    }
    
}

// MARK: Previews
struct FilterView_Previews: PreviewProvider {
    @State static var department: String = "Ariège"
    @State static var isSortDisplayed = true
    @State static var onlyDisplayed = false
    @State static var onlyFavs = false
    @State static var onlyLoops = false
    @State static var gr10Filter: Gr10Filter = .notgr10
    @State static var difficultyFilter: DifficultyFilter = .hard
    static var previews: some View {
        FilterView(onlyDisplayed: $onlyDisplayed, onlyFavs: $onlyFavs, onlyLoops: $onlyLoops, gr10Filter: $gr10Filter, difficultyFilter: $difficultyFilter, department: $department, isSortDisplayed: $isSortDisplayed)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
                .previewDisplayName("iPhone 14 Pro Max")
                .environment(\.colorScheme, .dark)
        
    }
}
