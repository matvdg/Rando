//
//  SortView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct SortView: View {
    
    @Binding var isActive: Bool
    @Binding var department: String
    @Binding var isSortDisplayed: Bool
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .center, spacing: 20.0) {
                
                Toggle(isOn: self.$isActive) {
                    Text("Active".localized)
                }
                .onTapGesture {
                    self.isActive.toggle()
                }
                
                Divider()
                
                Text("Departments".localized)
                    .font(.headline)
                
                Picker(selection: $department, label: Text("")) {
                    ForEach(TrailManager.shared.departments, id: \.self) { text in
                        Text(text)
                    }
                }
            .labelsHidden()
                
            }.padding()
                
                .navigationBarTitle(Text("Filter".localized), displayMode: .inline)
                .navigationBarItems(leading:
                    Button(action: {
                        self.isSortDisplayed = false
                        Feedback.selected()
                    }) {
                        Image(systemName: "chevron.down")
                    })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(maxWidth: 500)
        .frame(height: 400.0, alignment: .top)
        .shadow(radius: 10)
        .gesture(DragGesture().onEnded { value in
            if value.translation.height > 100 {
                self.isSortDisplayed = false
                Feedback.selected()
            }
        })
        
    }
    
}

// MARK: Previews
struct SortView_Previews: PreviewProvider {
    @State static var department: String = "Ariège"
    @State static var isSortDisplayed = true
    @State static var isActive = false
    static var previews: some View {
        SortView(isActive: $isActive, department: $department, isSortDisplayed: $isSortDisplayed)
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
                .previewDisplayName("iPhone 11 Pro Max")
                .environment(\.colorScheme, .dark)
        
    }
}
