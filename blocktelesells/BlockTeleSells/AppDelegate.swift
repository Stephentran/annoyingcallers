//
//  AppDelegate.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/2/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import UIKit
import  UserNotifications
import DataManager
//import Hue
import Presentation
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , PresentationControllerDelegate{

    var window: UIWindow?
    lazy var navigationController: UINavigationController = { [unowned self] in
        let controller = UINavigationController(rootViewController: self.presentationController)
        controller.view.backgroundColor = UIColor.brown

        return controller
    }()
    
    lazy var presentationController: PresentationController = {
        let controller = PresentationController(pages: [])
        controller.setNavigationTitle = false
        
        return controller
    }()
    
    lazy var leftButton: UIBarButtonItem = { [unowned self] in
        let button = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self.presentationController,
            action: #selector(PresentationController.moveBack))
    
        button.setTitleTextAttributes(
            [NSForegroundColorAttributeName : UIColor.gray],
            for: .normal)

            return button
        }()

    lazy var rightButton: UIBarButtonItem = { [unowned self] in
        let button = UIBarButtonItem(
            title: "Trang kế",
            style: .plain,
            target: self.presentationController,
            action: #selector(PresentationController.moveForward))
    
    
        button.setTitleTextAttributes(
            [NSForegroundColorAttributeName : UIColor.gray],
            for: .normal)

            return button
        }()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        let defaults = UserDefaults.standard

        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: Constants.KEY_CHECK_FIRST_TIME){
            print("App already launched : \(isAppAlreadyLaunchedOnce)")
        }else{
            presentationController.navigationItem.leftBarButtonItem = leftButton
            presentationController.navigationItem.rightBarButtonItem = rightButton
            presentationController.presentationDelegate = self
            configureSlides()
            //configureBackground()

            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
            
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
        }
        return true
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
    // Support for background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let viewControllers = window?.rootViewController?.childViewControllers
        {
            for viewController in viewControllers {
                if let mainViewController = viewController as? MainViewController {
                    if LocalDataManager.sharedInstance.loadAutoUpdate() == true {
                        mainViewController.updateData()
                        completionHandler(UIBackgroundFetchResult.newData)
                    }
                    
                }
            }
        }
    }
    
    
    func configureSlides() {
        var slides = [UIViewController]()
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "slide1")
        let vc2 = mainStoryboard.instantiateViewController(withIdentifier: "slide2")
        let vc3 = mainStoryboard.instantiateViewController(withIdentifier: "slide3")
        slides.append(vc1)
        slides.append(vc2)
        slides.append(vc3)
        presentationController.add(slides)
    }
    public func presentationController(_ presentationController: Presentation.PresentationController, didSetViewController viewController: UIViewController, atPage page: Int){
        if page == 2 {
            rightButton.title = "Kết thúc"
            rightButton.target =  self
            rightButton.action = #selector(self.finishGuideline)
        }else if page == 0 {
            leftButton.title = ""
            rightButton.target = self.presentationController
            rightButton.action = #selector(PresentationController.moveForward)
            leftButton.action = #selector(PresentationController.moveBack)
        }else{
            rightButton.title = "Trang kế"
            leftButton.title = "Trang trước"
            rightButton.target = self.presentationController
            rightButton.action = #selector(PresentationController.moveForward)
            leftButton.action = #selector(PresentationController.moveBack)
        }
    }
    @objc public func finishGuideline(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNav = mainStoryboard.instantiateViewController(withIdentifier: "mainNav")
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = mainNav
        window?.makeKeyAndVisible()
    }

}
