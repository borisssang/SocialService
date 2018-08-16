//
//  LocationCell.swift
//  Фандъкова
//
//  Created by Boris Angelov on 6.08.18.
//  Copyright © 2018 Melon. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell, UITextFieldDelegate{
    
    @IBOutlet weak var newButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        newButton?.setBackgroundImage(UIImage(named: "location2"), for: .normal)
        addressLabel?.alpha = 0
    }
    
    @IBOutlet weak var addressLabel: UILabel?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBOutlet weak var instructionLabel: UILabel!
    
    //animating the button
    @IBOutlet weak var buttonConstraint: NSLayoutConstraint!
    var animationHappened = false
    func performButtonAnimation(){
        instructionLabel.alpha = 0
        guard  animationHappened == false else {return}
        
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseIn, animations: {
            self.buttonConstraint.constant += self.contentView.bounds.width / 3
            self.contentView.layoutIfNeeded()
        }) { (_) in
            UIView.animate(withDuration: 0.6, delay: 0, options: .allowAnimatedContent, animations: {
                self.addressLabel?.alpha = 1
            })}
        animationHappened = true
    }
}
