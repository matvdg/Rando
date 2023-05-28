//
//  FilterView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

enum Gr10filter: String, CaseIterable {
    case gr10, notgr10, all
    var localized: String { rawValue.localized }
}

struct FilterView: View {
    
    @Binding var onlyDisplayed: Bool
    @Binding var onlyFavs: Bool
    @Binding var gr10filter: Gr10filter
    @Binding var department: String
    @Binding var isSortDisplayed: Bool
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .center, spacing: 20.0) {
                
                Toggle(isOn: self.$onlyDisplayed) {
                    Text("Displayed".localized)
                }
                .onTapGesture {
                    self.onlyDisplayed.toggle()
                }
                
                Toggle(isOn: self.$onlyFavs) {
                    Text("Favs".localized)
                }
                .onTapGesture {
                    self.onlyFavs.toggle()
                }
                
                Divider()
                
                HStack {
                    Text("gr10".localized)
                        .font(.headline)
                    Spacer()
                    Picker(selection: $gr10filter, label: Text("")) {
                        
                        ForEach(Gr10filter.allCases, id: \.self) { gr10filter in
                            Text(gr10filter.localized)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                HStack {
                    Text("Departments".localized)
                        .font(.headline)
                    Spacer()
                    Picker(selection: $department, label: Text("")) {
                        
                        ForEach(TrailManager.shared.departments, id: \.self) { text in
                            Text(text)
                        }
                    }
                    .pickerStyle(.menu)
                }
                            
            }
            .padding()
            .navigationBarTitle("Filter".localized, displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                isSortDisplayed = false
                Feedback.selected()
            }) {
                DismissButton()
            })
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .frame(maxWidth: 500)
        .frame(height: 330, alignment: .top)
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
    @State static var gr10filter: Gr10filter = .notgr10
    static var previews: some View {
        FilterView(onlyDisplayed: $onlyDisplayed, onlyFavs: $onlyFavs, gr10filter: $gr10filter, department: $department, isSortDisplayed: $isSortDisplayed)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
                .previewDisplayName("iPhone 14 Pro Max")
                .environment(\.colorScheme, .dark)
        
    }
}
