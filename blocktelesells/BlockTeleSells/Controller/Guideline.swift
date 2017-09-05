//
//  Guideline.swift
//  Phiền
//
//  Created by Stephen Tran on 8/22/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import UIKit
import Pages

class Guideline: NSObject {
    var numberOfPage: Int = 0
    var window: UIWindow?
    var baseViewController: UIViewController?
    var navigationController: UINavigationController?
    var pages: PagesController?
    
    
    lazy var leftButton: UIBarButtonItem = { [unowned self] in
        let button = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self.pages,
            action: #selector(PagesController.moveBack))
    
        button.setTitleTextAttributes(
            [NSForegroundColorAttributeName : UIColor.gray],
            for: .normal)

            return button
        }()

    lazy var rightButton: UIBarButtonItem = { [unowned self] in
        let button = UIBarButtonItem(
            title: "Sau",
            style: .plain,
            target: self.pages,
            action: #selector(PagesController.moveForward))
    
    
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
        
      
        configureSlides(slideType: slideType)
        pages?.navigationItem.leftBarButtonItem = leftButton
        pages?.navigationItem.rightBarButtonItem = rightButton
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
        for index in (0..<numberOfPage) {
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "slide")
            (vc as! SlideViewController).slideNumber = index + 1
            (vc as! SlideViewController).slideType = slideType
            (vc as! SlideViewController).guideline = self
            slides.append(vc)
        }
        pages = PagesController(slides)
        pages?.enableSwipe = true
        pages?.showBottomLine = true
        pages?.setNavigationTitle = true
        pages?.showPageControl = true
    }
    public func handleMove(atPage page: Int){
        if page == numberOfPage - 1 {
            rightButton.title = "Kết thúc"
            rightButton.target =  self
            rightButton.action = #selector(self.finishGuideline)
        }else if page == 0 {
            leftButton.title = ""
            rightButton.target = self.pages
            rightButton.action = #selector(PagesController.moveForward)
            leftButton.action = #selector(PagesController.moveBack)
        }else{
            rightButton.title = "Sau"
            leftButton.title = "Trước"
            rightButton.target = self.pages
            rightButton.action = #selector(PagesController.moveForward)
            leftButton.action = #selector(PagesController.moveBack)
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
    
    static func showGuideLine(navigationController: UINavigationController, pagesControllerDelegate: PagesControllerDelegate, slideType: SlideType, baseViewController: UIViewController) -> Guideline {
            let window = UIWindow(frame: UIScreen.main.bounds)
            let guideline = Guideline(window: window, navigationController: navigationController, slideType: slideType, baseViewController: baseViewController)
            guideline.pages?.pagesDelegate = pagesControllerDelegate
            navigationController.pushViewController((guideline.pages)!, animated: true)
            return guideline
        
    }
}
