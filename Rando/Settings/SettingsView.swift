//
//  SettingsView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 13/06/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import StoreKit
import MessageUI

let maisondarlosUrl = URL(string: "https://maisondarlos.fr")!


struct SettingsView: View {
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let systemVersion = UIDevice.current.systemVersion
    let modelName = UIDevice.current.model
    let recipientEmail = "contact@maisondarlos.fr"
    let subject = "Rando Pyrénées"
    
    @State private var isExpanded = false
    
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
                    
                    NavigationLink {
                        RemoveLayerView()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "map")
                            Text("DeleteLayer")
                        }
                    }.tint(.accentColor)
                    
                    DisclosureGroup(
                        isExpanded: $isExpanded,
                        content: {
                            Text("AboutMe")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        },
                        label: {
                            HStack(spacing: 10) {
                                Image(systemName: "questionmark.circle")
                                Text("About")
                            }
                        }
                    ).tint(.gray)
                    
                    NavigationLink {
                        WebView(url: maisondarlosUrl)
                            .navigationTitle("Maison d'Arlos")
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "globe")
                            Text("Maison d'Arlos")
                        }
                    }.tint(.accentColor)
                    
                    Button {
#if targetEnvironment(macCatalyst)
                        UIApplication.shared.open(URL(string: "https://apps.apple.com/fr/app/rando-pyr%C3%A9n%C3%A9es/id1523741976")!)
#else
                        rateApp()
#endif
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "star")
                            Text("RateApp")
                        }
                    }.foregroundColor(.primary)
                    
                    
                    Button {
                        openEmailApp()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "envelope")
                            Link("ContactMe", destination: URL(string: "mailto:contact@maisondarlos.fr")!)
                        }
                    }.foregroundColor(.primary)
                    
                    
                    
                }
            }
            .accentColor(.tintColor)
            HStack {
                Image(systemName: "sidebar.left")
                    .imageScale(.large)
                Text("SelectInSidebar")
            }
        }
        
        
    }
    
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func openEmailApp() {
        guard MFMailComposeViewController.canSendMail() else { return }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            let body = "v\(appVersion), system: \(systemVersion), device: \(modelName)"
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.setToRecipients([recipientEmail])
            mailComposeViewController.setSubject(subject)
            mailComposeViewController.setMessageBody(body, isHTML: false)
            
            rootViewController.present(mailComposeViewController, animated: true)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}