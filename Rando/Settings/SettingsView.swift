//
//  SettingsView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 13/06/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import UIKit
import StoreKit
import MessageUI
import TipKit

let maisondarlosUrl = URL(string: "https://maisondarlos.fr")!
let systemVersion = UIDevice.current.systemVersion
let modelName = UIDevice.modelName
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

struct SettingsView: View {
    
    @State private var showMailView = false
    @State private var averageSpeed: Double = UserDefaults.averageSpeed
    @Binding var selection: Int
    @State private var showShareSheet = false
    var trailManager = TrailManager.shared
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .center, spacing: 16) {
                
                Spacer()
                
                AppIcon()
                
                VStack(alignment: .center, spacing: 8) {
                    Text("Rando Pyrénées").fontWeight(.heavy).fontWidth(.compressed)
                    Text("v\(appVersion)").fontWeight(.light)
                }
                
                ShareLink("shareApp", item: URL(string: "https://apps.apple.com/fr/app/rando-pyr%C3%A9n%C3%A9es/id1523741976")!).foregroundColor(.primary)
                
                List {
                    
                    Button {
                        trailManager.removeAllTrailsVisibleOnTheMap()
                        Feedback.success()
                        selection = 0
                    } label: {
                        Label("cleanMapTrails", systemImage: "eye.slash")
                    }
                    
                    Button {
                        trailManager.showGR10andHRPOnTheMap()
                        Feedback.success()
                        selection = 0
                    } label: {
                        Label("showGHR", systemImage: "eye")
                    }
                    
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("shareMyPosition", systemImage: "mappin")
                    }
                    
                    
                    NavigationLink {
                        RemoveLayerView()
                    } label: {
                        Label("deleteLayer", systemImage: "map")
                    }.tint(.accentColor)
                    
                    
                    DisclosureGroup(
                        content: {
                            VStack(alignment: .center, spacing: 16) {
                                Stepper(averageSpeed.toSpeedString, value: $averageSpeed, in: 0.3...2.7, step: 0.1) { _ in
                                    Feedback.selected()
                                    UserDefaults.averageSpeed = averageSpeed
                                }
                                Text("averageSpeedDescription")
                                Button {
                                    Feedback.success()
                                    averageSpeed = defaultAverageSpeed
                                    UserDefaults.averageSpeed = defaultAverageSpeed
                                } label: {
                                    Text("resetAverageSpeed").foregroundColor(.primary)
                                        .padding(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(.secondary)
                            }
                            .font(.subheadline)
                        },
                        label: {
                            Label("averageSpeed", systemImage: "speedometer")
                        }
                    )
                    
                    if #available(iOS 17.0, *) {
                        Button {
                            try? Tips.resetDatastore()
                            Feedback.success()
                            selection = 0
                            try? Tips.configure([.displayFrequency(.hourly)])
                        } label: {
                            Label("restoreTips", systemImage: "lightbulb.max")
                        }
                    }
                    
                    DisclosureGroup(
                        content: {
                            Text("aboutMe")
                                .font(.subheadline)
                        },
                        label: {
                            Label("about", systemImage: "questionmark.circle")
                        }
                    )
                    
                    DisclosureGroup(
                        content: {
                            VStack(alignment: .center, spacing: 16) {
                                Text("restoreMessage")
                                Button {
                                    trailManager.restoreDemoTrails()
                                    Feedback.success()
                                    selection = 1
                                } label: {
                                    Text("restore").foregroundColor(.primary)
                                        .padding(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(.secondary)
                            }
                            .font(.subheadline)
                        },
                        label: {
                            Label("restore", systemImage: "lifepreserver")
                        }
                    )
                    
                    NavigationLink {
                        WebView(url: maisondarlosUrl)
                            .navigationTitle("Maison d'Arlos")
                    } label: {
                        Label("Maison d'Arlos", systemImage: "globe")
                    }
                    
                    Button {
#if targetEnvironment(macCatalyst)
                        UIApplication.shared.open(URL(string: "https://apps.apple.com/fr/app/rando-pyr%C3%A9n%C3%A9es/id1523741976")!)
#else
                        rateApp()
#endif
                    } label: {
                        Label("rateApp", systemImage: "star")
                    }.foregroundColor(.primary)
                    
                    if MFMailComposeViewController.canSendMail() {
                        Button {
                            showMailView = true
                        } label: {
                            Label("contactMe", systemImage: "envelope")
                        }.foregroundColor(.primary)
                    }
                    
                }
                .foregroundColor(.primary)
            }
            .accentColor(.tintColor)
            HStack {
                Image(systemName: "sidebar.left")
                    .imageScale(.large)
                Text("selectInSidebar")
            }
        }
        .sheet(isPresented: $showMailView, content: {
            MailView()
        })
        .sheet(isPresented: $showShareSheet, content: {
            ActivityView()
        })
        
    }
    
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
}


#Preview {
    SettingsView(selection: .constant(0))
}

struct ActivityView: UIViewControllerRepresentable {
    
    private let text: String = "Voici ma position sur l'app Rando ! rando://position?lat=\(LocationManager.shared.currentPosition.coordinate.latitude)&lng=\(LocationManager.shared.currentPosition.coordinate.longitude)"
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
