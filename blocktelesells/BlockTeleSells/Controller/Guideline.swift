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
    var numberOfPage: Int = 0
    var window: UIWindow?
    var baseViewController: UIViewController?
    var navigationController: UINavigationController?
    public lazy var presentationController: PresentationController = {
        let controller = PresentationController(pages: [])
        controller.setNavigationTitle = true
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
            title: "Sau",
            style: .plain,
            target: self.presentationController,
            action: #selector(PresentationController.moveForward))
    
    
        button.setTitleTextAttributes(
            [NSForegroundColorAttributeName : UIColor.gray],
            for: .normal)

            return button
        }()
    init(window: UIWindow, navigationController: UINavigationController, slideType: SlideType, baseViewController: UIViewController ) {
        super.init()
        self.window = window
        self.navigationController = navigationController
        self.baseViewController = baseViewController
        presentationController.navigationItem.leftBarButtonItem = leftButton
        presentationController.navigationItem.rightBarButtonItem = rightButton

        configureSlides(slideType: slideType)
    }
    func configureSlides(slideType: SlideType ) {
        var slides = [UIViewController]()
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        switch slideType {
            case .ActivteCallBlock:
                numberOfPage = 3
                
            case .GetNumberFromHistory:
                numberOfPage = 5
                
        }
        for var  index in (0..<numberOfPage) {
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "slide")
            (vc as! SlideViewController).slideNumber = index + 1
            (vc as! SlideViewController).slideType = slideType
            (vc as! SlideViewController).guideline = self
            slides.append(vc)
        }
        
        presentationController.add(slides)
    }
    public func handleMove(atPage page: Int){
        if page == numberOfPage - 1 {
            rightButton.title = "Kết thúc"
            rightButton.target =  self
            rightButton.action = #selector(self.finishGuideline)
        }else if page == 0 {
            leftButton.title = ""
            rightButton.target = self.presentationController
            rightButton.action = #selector(PresentationController.moveForward)
            leftButton.action = #selector(PresentationController.moveBack)
        }else{
            rightButton.title = "Sau"
            leftButton.title = "Trước"
            rightButton.target = self.presentationController
            rightButton.action = #selector(PresentationController.moveForward)
            leftButton.action = #selector(PresentationController.moveBack)
        }
    }
    @objc public func finishGuideline(){
        navigationController?.popToViewController(baseViewController!, animated: true)
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: Constants.KEY_CHECK_FIRST_TIME) != true {
            defaults.set(true, forKey: Constants.KEY_CHECK_FIRST_TIME)
            print("App launched first time")
        }
    }
    
    static func showGuideLine(navigationController: UINavigationController, presentationControllerDelegate: PresentationControllerDelegate, slideType: SlideType, baseViewController: UIViewController) -> Guideline {
            let window = UIWindow(frame: UIScreen.main.bounds)
            let guideline = Guideline(window: window, navigationController: navigationController, slideType: slideType, baseViewController: baseViewController)
            guideline.presentationController.presentationDelegate = presentationControllerDelegate
            navigationController.pushViewController((guideline.presentationController), animated: true)
            return guideline
        
    }
}
