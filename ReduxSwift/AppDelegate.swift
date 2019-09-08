//
//  AppDelegate.swift
//  ReduxSwift
//
//  Created by David Thorn on 07.09.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import UIKit

public let PRESENT: String = "PRESENT_VIEW_CONTROLLER"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let viewModel = PeopleModel.init(items: [])
        
        let vc = PeopleListViewController.instance(viewModel: viewModel)
        vc.title = "Home"
        let nav = UINavigationController.init(rootViewController: vc)
        
        presentation_store_initialise(controller: nav)
        model_store_initialise()
        transformer_store_initialise()
        
        
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        
        return true
    }

   


}

