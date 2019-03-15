//
//  AppDelegate.swift
//  Fractals
//
//  Created by Paweł Wszeborowski on 12/03/2019.
//  Copyright © 2019 Paweł Wszeborowski. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    private let rootViewController = MainViewController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window?.contentView?.addSubview(rootViewController.view)
        rootViewController.view.translatesAutoresizingMaskIntoConstraints = false
        guard let contentView = window?.contentView else { return }
        NSLayoutConstraint.activate([
            rootViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            rootViewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            rootViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rootViewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

