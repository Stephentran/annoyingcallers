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
    var baseViewController: UIViewController?
    var navigationController: UINavigationController?
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
    init(window: UIWindow, navigationController: UINavigationController, typeTutorial: Int, baseViewController: UIViewController ) {
        super.init()
        self.window = window
        self.navigationController = navigationController
        self.baseViewController = baseViewController
        presentationController.navigationItem.leftBarButtonItem = leftButton
        presentationController.navigationItem.rightBarButtonItem = rightButton

        configureSlides(typeTutorial: typeTutorial)
    }
    func configureSlides(typeTutorial: Int ) {
        var slides = [UIViewController]()
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "slide")
        let vc2 = mainStoryboard.instantiateViewController(withIdentifier: "slide")
        let vc3 = mainStoryboard.instantiateViewController(withIdentifier: "slide")
        if typeTutorial == 1 {
            (vc1 as! SlideViewController).slideNumber = 1
            (vc2 as! SlideViewController).slideNumber = 2
            (vc3 as! SlideViewController).slideNumber = 3
        }else{
            (vc1 as! SlideViewController).slideNumber = 4
            (vc2 as! SlideViewController).slideNumber = 5
            (vc3 as! SlideViewController).slideNumber = 6
        }
        
        
        (vc1 as! SlideViewController).guideline = self
        (vc2 as! SlideViewController).guideline = self
        (vc3 as! SlideViewController).guideline = self
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
        navigationController?.popToViewController(baseViewController!, animated: true)
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: Constants.KEY_CHECK_FIRST_TIME)
        print("App launched first time")
    }
    
    static func showGuideLine(navigationController: UINavigationController, presentationControllerDelegate: PresentationControllerDelegate, typeTutorial: Int, baseViewController: UIViewController) -> Guideline {
            let window = UIWindow(frame: UIScreen.main.bounds)
            let guideline = Guideline(window: window, navigationController: navigationController, typeTutorial: typeTutorial, baseViewController: baseViewController)
            guideline.presentationController.presentationDelegate = presentationControllerDelegate
            navigationController.pushViewController((guideline.presentationController), animated: true)
            return guideline
        
    }
}
