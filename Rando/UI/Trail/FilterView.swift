//
//  FilterView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct FilterView: View {
    
    @Binding var onlyDisplayed: Bool
    @Binding var onlyFavs: Bool
    @Binding var onlyGR10: Bool
    @Binding var department: String
    @Binding var isSortDisplayed: Bool
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .center, spacing: 20.0) {
                
                HStack {
                    Text("Filter".localized)
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                    Button(action: {
                        self.isSortDisplayed = false
                        Feedback.selected()
                    }) {
                        DismissButton()
                    }
                }
                
                Divider()
                
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
                
                Toggle(isOn: self.$onlyGR10) {
                    Text("GR10filtering".localized)
                }
                .onTapGesture {
                    self.onlyGR10.toggle()
                }
                
                Divider()
    
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
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
    @State static var onlyGR10 = false
    static var previews: some View {
        FilterView(onlyDisplayed: $onlyDisplayed, onlyFavs: $onlyFavs, onlyGR10: $onlyGR10, department: $department, isSortDisplayed: $isSortDisplayed)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
                .previewDisplayName("iPhone 14 Pro Max")
                .environment(\.colorScheme, .dark)
        
    }
}
