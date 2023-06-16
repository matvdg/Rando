//
//  EditDescriptionView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 16/06/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct EditDescriptionView: View {
    
    var trail: Trail
    @State var textFieldInput: String = ""
    @Binding var showDescriptionSheet: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                TextField("EditDescription", text: $textFieldInput, axis: .vertical)
                    .lineLimit(10...100)
                    .padding()
                    .focused($isFocused)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.sentences)
                HStack(alignment: .center, spacing: 8) {
                    Spacer()
                    Button {
                        showDescriptionSheet = false
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.primary)
                            .padding(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                    }
                    .buttonStyle(.bordered)
                    .tint(.lightgray)
                    Spacer()
                    Button {
                        trail.description = textFieldInput
                        TrailManager.shared.save(trail: trail)
                        showDescriptionSheet = false
                    } label: {
                        Text("Save")
                            .foregroundColor(.primary)
                            .padding(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                            
                    }
                    .buttonStyle(.bordered)
                    .tint(.tintColorTabBar)
                    Spacer()
                }

                Spacer()
            }
            
            .navigationBarTitle("Description", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showDescriptionSheet = false
                Feedback.selected()
            }) {
                DismissButton()
            })
            .onAppear {
                textFieldInput = trail.description
                isFocused = true
            }
        }
                    
    }
}

struct EditDescriptionView_Previews: PreviewProvider {
    
    @State static var showDescriptionSheet: Bool = true
    
    static var previews: some View {
        EditDescriptionView(trail: Trail(), showDescriptionSheet: $showDescriptionSheet)
    }
}
