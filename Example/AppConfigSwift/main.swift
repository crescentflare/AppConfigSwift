//
//  main.swift
//  AppConfigSwift
//
//  The main swift file to activate the custom application class
//

import UIKit

UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)),
    NSStringFromClass(Application.self),
    NSStringFromClass(AppDelegate.self)
)
