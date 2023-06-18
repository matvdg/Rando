//
//  MailView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 17/06/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    
    let recipientEmail = "contact@maisondarlos.fr"
    let subject = "Rando Pyrénées"
    let mailComposeViewController = MFMailComposeViewController()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
        
        var parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
            super.init()
            parent.mailComposeViewController.delegate = self
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            // Traiter les résultats de l'envoi du courrier électronique ici
            controller.dismiss(animated: true)
        }
        
    }
        
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        mailComposeViewController.mailComposeDelegate = context.coordinator
        let body = "Message: \n\n\n\n\n\n Technical data: \n Rando v\(appVersion), system: \(systemVersion), device: \(modelName)"
        mailComposeViewController.setToRecipients([recipientEmail])
        mailComposeViewController.setSubject(subject)
        mailComposeViewController.setMessageBody(body, isHTML: false)
        return mailComposeViewController
    }
}

struct MailView_Previews: PreviewProvider {
    static var previews: some View {
        MailView()
    }
}
