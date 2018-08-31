//
//  DataController.swift
//  Фандъкова
//
//  Created by Boris Angelov on 10.08.18.
//  Copyright © 2018 Melon. All rights reserved.
//

import UIKit
import CoreLocation
class DataController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        popUpVIew.layer.cornerRadius = 10
        popUpVIew.layer.masksToBounds = true
        }
    
    @IBAction func resetForm(_ sender: UIButton) {
        let vc = (self.presentingViewController as? UINavigationController)?.viewControllers[0] as! FormTableController
        vc.resetForm(self)
        vc.navigationController?.setNavigationBarHidden(false, animated: true)
        _ = navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var popUpVIew: UIView!
    var forms = [FormData]()
}
