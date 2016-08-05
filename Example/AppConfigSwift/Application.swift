//
//  Application.swift
//  AppConfigSwift
//
//  Subclasses UIApplication to support shake gestures
//

import UIKit
import AppConfigSwift

class Application: UIApplication {

    override func sendEvent(event: UIEvent) {
        super.sendEvent(event)
        if AppConfigStorage.sharedManager.isActivated() && event.subtype == .MotionShake {
            AppConfigManageViewController.launchFromShake()
        }
    }

}
