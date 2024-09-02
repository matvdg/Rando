//
//  SettingsView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 13/06/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import UIKit
import StoreKit
import MessageUI

let maisondarlosUrl = URL(string: "https://maisondarlos.fr")!
let systemVersion = UIDevice.current.systemVersion
let modelName = UIDevice.modelName
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

struct SettingsView: View {
    
    @State private var showMailView = false
    @State private var averageSpeed: Double = UserDefaults.averageSpeed
    @Binding var selection: Int
    @State private var showShareSheet = false
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .center, spacing: 16) {
                
                Spacer()
                
                AppIcon()
                
                VStack(alignment: .center, spacing: 8) {
                    Text("Rando Pyrénées").fontWeight(.heavy).fontWidth(.compressed)
                    Text("v\(appVersion)").fontWeight(.light)
                }
                
                ShareLink("ShareApp", item: URL(string: "https://apps.apple.com/fr/app/rando-pyr%C3%A9n%C3%A9es/id1523741976")!).foregroundColor(.primary)
                
                List {
                    
                    Button {
                        TrailManager.shared.removeAllTrailsVisibleOnTheMap()
                        Feedback.success()
                        selection = 0
                    } label: {
                        Label("Clean visible trails from the map", systemImage: "eye.slash")
                    }
                    
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("ShareMyPosition", systemImage: "mappin")
                    }
                    
                    
                    NavigationLink {
                        RemoveLayerView()
                    } label: {
                        Label("DeleteLayer", systemImage: "map")
                    }.tint(.accentColor)
                    
                    
                    DisclosureGroup(
                        content: {
                            VStack(alignment: .center, spacing: 16) {
                                Stepper(averageSpeed.toSpeedString, value: $averageSpeed, in: 0.3...2.7, step: 0.1) { _ in
                                    Feedback.selected()
                                    UserDefaults.averageSpeed = averageSpeed
                                }
                                Text("AverageSpeedDescription")
                                Button {
                                    Feedback.success()
                                    averageSpeed = defaultAverageSpeed
                                    UserDefaults.averageSpeed = defaultAverageSpeed
                                } label: {
                                    Text("ResetAverageSpeed").foregroundColor(.primary)
                                        .padding(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(.secondary)
                            }
                            .font(.subheadline)
                        },
                        label: {
                            Label("AverageSpeed", systemImage: "speedometer")
                        }
                    )
                    
                    DisclosureGroup(
                        content: {
                            Text("AboutMe")
                                .font(.subheadline)
                        },
                        label: {
                            Label("About", systemImage: "questionmark.circle")
                        }
                    )
                    
                    DisclosureGroup(
                        content: {
                            VStack(alignment: .center, spacing: 16) {
                                Text("RestoreMessage")
                                Button {
                                    TrailManager.shared.restoreDemoTrails()
                                    Feedback.success()
                                    selection = 1
                                } label: {
                                    Text("Restore").foregroundColor(.primary)
                                        .padding(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(.secondary)
                            }
                            .font(.subheadline)
                        },
                        label: {
                            Label("Restore", systemImage: "lifepreserver")
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
                        Label("RateApp", systemImage: "star")
                    }.foregroundColor(.primary)
                    
                    if MFMailComposeViewController.canSendMail() {
                        Button {
                            showMailView = true
                        } label: {
                            Label("ContactMe", systemImage: "envelope")
                        }.foregroundColor(.primary)
                    }
                    
                }
                .foregroundColor(.primary)
            }
            .accentColor(.tintColor)
            HStack {
                Image(systemName: "sidebar.left")
                    .imageScale(.large)
                Text("SelectInSidebar")
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


struct SettingsView_Previews: PreviewProvider {
    @State static private var selection = 0
    static var previews: some View {
        SettingsView(selection: $selection)
    }
}

struct ActivityView: UIViewControllerRepresentable {
    
    private let text: String = "Voici ma position sur l'app Rando ! rando://position?lat=\(LocationManager.shared.currentPosition.coordinate.latitude)&lng=\(LocationManager.shared.currentPosition.coordinate.longitude)"

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
