//
//  EnabledFiltersView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 27/05/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct EnabledFiltersView: View {
    
    @Binding var onlyDisplayed: Bool
    @Binding var onlyFavs: Bool
    @Binding var gr10filter: Gr10filter
    @Binding var department: String
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(alignment: .center, spacing: 8) {
                
                Spacer()
                
                Button {
                    department = "all".localized
                } label: {
                    FilterButton(label: department)
                }
                .isHidden(department == "all".localized, remove: true)
                
                Button {
                    gr10filter = .all
                } label: {
                    FilterButton(label: gr10filter.localized)
                }
                .isHidden(gr10filter == .all, remove: true)
                
                Button {
                    onlyFavs.toggle()
                } label: {
                    FilterButton(label: "Favs".localized)
                }
                .isHidden(!onlyFavs, remove: true)
                
                Button {
                    onlyDisplayed.toggle()
                } label: {
                    FilterButton(label: "Displayed".localized)
                }
                .isHidden(!onlyDisplayed, remove: true)
                
                Spacer()
            }
        }
        .background(.clear)
        .foregroundColor(.primary)
        
    }
}

struct EnabledFiltersView_Previews: PreviewProvider {
    
    @State static var onlyDisplayed: Bool = true
    @State static var onlyFavs: Bool = true
    @State static var gr10filter: Gr10filter = .notgr10
    @State static var department: String = "Ariège"
    
    static var previews: some View {
        EnabledFiltersView(onlyDisplayed: $onlyDisplayed, onlyFavs: $onlyFavs, gr10filter: $gr10filter, department: $department)
    }
}
