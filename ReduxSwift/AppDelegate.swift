//
//  AppDelegate.swift
//  ReduxSwift
//
//  Created by David Thorn on 07.09.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        subscribe(action: "PEOPLE_ALL_ACTION", transformer: (id: UUID.init().uuidString , handler: { data in
            print("transform called for people all")
            return data
        }))
        
        registerPeople()
        
        let viewModel = PeopleModel.init(items: [])
        
        let vc = ReduxHomeViewController.instance(viewModel: viewModel)
        vc.title = "Home"
        let nav = UINavigationController.init(rootViewController: vc)
        
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        
        return true
    }

   


}

