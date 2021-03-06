//
//  AppDelegate.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/7/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        navigationController?.navigationBar.barTintColor = UIColor(red: 0.03, green: 0.13, blue: 0.91, alpha: 1.0)
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
//        navigationController?.navigationBar.tintColor = UIColor.white;
        
        var navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white;
        navigationBarAppearace.barTintColor = UIColor(red: 0.03, green: 0.13, blue: 0.91, alpha: 1.0)
        navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        FirebaseApp.configure()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        UITabBar.appearance().tintColor = UIColor(red: 0.03, green: 0.13, blue: 0.91, alpha: 1.0)
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let homeController = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! UITabBarController
        if Auth.auth().currentUser != nil {
            // User is signed in.
            // ...
            self.window?.rootViewController = homeController
        }
        else {
            self.window?.rootViewController = loginController
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Override point for customization after application launch.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            
            let sourceApplication =  options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
            let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
            
            let googleHandler = GIDSignIn.sharedInstance().handle(
                url,
                sourceApplication: sourceApplication,
                annotation: annotation )
            
            let facebookHandler = FBSDKApplicationDelegate.sharedInstance().application (
                application,
                open: url,
                sourceApplication: sourceApplication,
                annotation: annotation )
            
            return googleHandler || facebookHandler
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

