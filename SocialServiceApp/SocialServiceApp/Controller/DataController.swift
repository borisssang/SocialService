//
//  DataController.swift
//  Фандъкова
//
//  Created by Boris Angelov on 10.08.18.
//  Copyright © 2018 Melon. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class DataController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        popUpVIew.layer.cornerRadius = 10
        popUpVIew.layer.masksToBounds = true
        }
    
    //TODO: populate municipalities
    var municipalities = [
        Municipality(name: "Sofia", location: CLLocationCoordinate2D.init()),
        Municipality(name: "Blagoevgrad", location: CLLocationCoordinate2D.init()),
        Municipality(name: "Varna", location: CLLocationCoordinate2D.init())
    ]
    
    var forms = [FormData]()
    {
        didSet{
            guard let newForm = self.forms.last else {return}
            sendSignal(for: newForm)
        }
    }
    
    @IBAction func resetForm(_ sender: UIButton) {
        let vc = (self.presentingViewController as? UINavigationController)?.viewControllers[0] as! FormTableController
        vc.resetForm(self)
        vc.navigationController?.setNavigationBarHidden(false, animated: true)
        _ = navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var popUpVIew: UIView!
    
     //send signal to the corresponding municipality
    func sendSignal(for form: FormData){

        //location of the user
        guard let location = form.getLocation() else {return}
        
        let location2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)
        
        //going through the municipalities's locations
        for municipality in municipalities {
            guard let municipalityLocation = municipality.getLocation() else {return}
            if location2D.liesInsideRegion(region: [municipalityLocation]){
                municipality.sendForm(form: form)
            }
        }
    }
}
