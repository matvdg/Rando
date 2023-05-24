//
//  ContentView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit
import HidableTabView

struct ContentView: View {
    
    @State private var selection = 0
    @State var selectedLayer: Layer = UserDefaults.currentLayer
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                HomeView(selectedLayer: $selectedLayer)
                    .tabItem {
                        Image(systemName: "map")
                    }
                    .tag(0)
                TrailView(selectedLayer: $selectedLayer)
                    .tabItem {
                        Image(systemName: "point.topleft.down.curvedto.point.filled.bottomright.up")
                    }
                    .tag(1)
                PoiView(selectedLayer: $selectedLayer)
                    .tabItem {
                        Image(systemName: "mappin.and.ellipse")
                    }
                    .tag(2)
            }
        }
        .accentColor(Color.tintColorTabBar)
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            // correct the transparency bug for Navigation bars
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            UITabBar.showTabBar(animated: false)
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { orientation in
            let orientation = UIDevice.current.orientation
            if UIDevice.current.userInterfaceIdiom == .phone {
                if orientation == .landscapeLeft || orientation == .landscapeRight {
                    UITabBar.hideTabBar(animated: false)
                } else {
                    UITabBar.showTabBar(animated: false)
                }
            }
        }
    }
        
}


// MARK: Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
                .previewDisplayName("iPhone 14 pro")
                .environment(\.colorScheme, .light)
        }
    }
}
