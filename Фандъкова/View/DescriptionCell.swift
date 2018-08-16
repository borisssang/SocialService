//
//  DescriptionCell.swift
//  Фандъкова
//
//  Created by Boris Angelov on 6.08.18.
//  Copyright © 2018 Melon. All rights reserved.
//

import UIKit

protocol DescriptionDelegate {
    func descriptionUpdated(text: String)
}

class DescriptionCell: UITableViewCell, UITextViewDelegate {
    
    var delegate: DescriptionDelegate?
    
    @IBOutlet weak var textView: UITextView!{
        didSet{
            textView.delegate = self
            textView?.sizeThatFits(CGSize(width: (textView?.frame.size.width)!, height: (textView?.frame.size.height)!))
            textView.text = "Please, describe the issue..."
            textView.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0.7435787671)
            setUpToolBar()
            self.textView.inputAccessoryView = toolbar
        }
    }
    
    var toolbar:UIToolbar = UIToolbar()
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0.7435787671){
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        delegate?.descriptionUpdated(text: textView.text)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Please, describe the issue..."
            textView.textColor = UIColor.lightGray
        }
        delegate?.descriptionUpdated(text: textView.text)
    }
    
    func setUpToolBar(){
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: contentView.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        
        let doneBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.barTintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0.7435787671)
        self.toolbar = toolbar
    }
    
    @objc func doneButtonAction() {
        self.contentView.endEditing(true)
    }
}
