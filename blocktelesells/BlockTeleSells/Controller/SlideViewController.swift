//
//  SlideViewController.swift
//  Phiền
//
//  Created by Stephen Tran on 8/28/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import UIKit
enum SlideType {
    case ActivteCallBlock
    case GetNumberFromHistory
}
class SlideViewController: UIViewController {
    @IBAction func exitAction(_ sender: Any) {
        guideline?.finishGuideline()
    }
    @IBOutlet weak var slideImage: UIImageView!
    var slideNumber: Int?
    var guideline: Guideline?
    var slideType: SlideType = SlideType.ActivteCallBlock
    override func viewDidLoad() {
        super.viewDidLoad()
        if slideNumber == 1 {
            slideImage.image = #imageLiteral(resourceName: "Phien_guideline_1")
        }else if slideNumber == 2 {
            slideImage.image = #imageLiteral(resourceName: "Phien_guideline_2")
        }else if slideNumber == 3 {
            slideImage.image = #imageLiteral(resourceName: "Phien_guideline_3")
        }else if slideNumber == 4 {
            slideImage.image = #imageLiteral(resourceName: "Phien_guideline_4")
        }else if slideNumber == 5 {
            slideImage.image = #imageLiteral(resourceName: "Phien_guideline_5")
        }else if slideNumber == 6 {
            slideImage.image = #imageLiteral(resourceName: "Phien_guideline_6")
        }
        switch slideType {
            case .ActivteCallBlock:
                title = "Kích hoạt Phiền"
                if slideNumber == 1 {
                    slideImage.image = #imageLiteral(resourceName: "Phien_guideline_1")
                }else if slideNumber == 2 {
                    slideImage.image = #imageLiteral(resourceName: "Phien_guideline_2")
                }else if slideNumber == 3 {
                    slideImage.image = #imageLiteral(resourceName: "Phien_guideline_3")
                }
            case .GetNumberFromHistory:
                title = "Lấy số từ lịch sử"
                if slideNumber == 1 {
                    slideImage.image = #imageLiteral(resourceName: "Phien_guideline_01")
                }else if slideNumber == 2 {
                    slideImage.image = #imageLiteral(resourceName: "Phien_guideline_02")
                }else if slideNumber == 3 {
                    slideImage.image = #imageLiteral(resourceName: "Phien_guideline_4")
                }else if slideNumber == 4 {
                    slideImage.image = #imageLiteral(resourceName: "Phien_guideline_5")
                }else if slideNumber == 5 {
                    slideImage.image = #imageLiteral(resourceName: "Phien_guideline_6")
                }
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
