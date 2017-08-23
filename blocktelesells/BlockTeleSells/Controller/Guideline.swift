//
//  Guideline.swift
//  Phiền
//
//  Created by Stephen Tran on 8/22/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import UIKit
import Presentation
class Guideline: NSObject {
    var window: UIWindow?
    public lazy var navigationController: UINavigationController = { [unowned self] in
        let controller = UINavigationController(rootViewController: self.presentationController)
        controller.view.backgroundColor = UIColor.gray

        return controller
    }()
    
    public lazy var presentationController: PresentationController = {
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
    init(window: UIWindow) {
        super.init()
        self.window = window
        presentationController.navigationItem.leftBarButtonItem = leftButton
        presentationController.navigationItem.rightBarButtonItem = rightButton

        configureSlides()
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
    public func handleMove(atPage page: Int){
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
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
        print("App launched first time")
    }
}
