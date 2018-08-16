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

    @IBOutlet weak var popUpVIew: UIView!
    var forms = [FormData]()
}
