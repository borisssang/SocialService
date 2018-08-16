//
//  FormTableController.swift
//  Фандъкова
//
//  Created by Boris Angelov on 6.08.18.
//  Copyright © 2018 Melon. All rights reserved.
//

import UIKit
import CoreLocation

class FormTableController: UITableViewController, DescriptionDelegate, LocationDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //delegates used for getting the data from the cells
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        descriptionCell.delegate = self
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Futura", size: 20)!]
        
        //gesture to disable the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper")!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if imageSet == true {
            self.performCameraAnimation()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: MODEL
    var user: UserEntity?
    var formImage: UIImage?{
        get {
            if let image = cameraImage.image{
                return image
            }
            return UIImage()
        }
    }
    var formAddress: String?{
        didSet{
            guard formAddress != nil else {return}
            locationCell.addressLabel?.text = self.formAddress!
        }
    }
    var formLocation: CLLocation?
    let categories = ["Streets", "Pollution", "Facilities", "Construction", "Other"]
    
    var selectedCategory: String?
    var formDescription: String?
    
    @IBOutlet weak var cameraImage: ScaledHeightImageView!{
        didSet{
            self.cameraImage.alpha = 0
        }
    }
    
    @IBOutlet weak var cameraInstructionLabel: UILabel!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    //delegation updates
    @IBOutlet weak var descriptionCell: DescriptionCell!
    @IBOutlet weak var locationCell: LocationCell!
    
    func descriptionUpdated(text: String) {
        formDescription = text
    }
    
    func setLocation(location: CLLocation, address: String){
        formLocation = location
        formAddress = address
    }
    
    func locationChanged(){
        locationCell.performButtonAnimation()
    }
    
    //MARK: Actions
    
    @IBAction func showCamera(_ sender: UIButton) {
        setImage()
    }
    
    func setImage(){
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            self.cameraImage.image = image
            self.imageSet = true
            self.cameraImage.setNeedsDisplay()
            self.cameraInstructionLabel.alpha = 0
        }
    }
    
    @IBAction func showMap(_ sender: UIButton) {
        performSegue(withIdentifier: "showMap", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? LocationViewController{
            if segue.identifier == "showMap" {
                destinationVC.delegate = self
            }
        } else if let destinationVC = segue.destination as? DataController {
            guard user != nil && formAddress != nil && formImage != nil && formLocation != nil && formDescription != nil else { showAlert()
                return}
            let template = FormData(user: user!, image: formImage!, address: formAddress!, location: formLocation!, category: selectedCategory!, description: formDescription!)
            destinationVC.forms.append(template)
        }
    }
    
    @IBAction func showData(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showData", sender: self)
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Oops", message: "Make sure you have added a photo, address and description", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("adsa")
            case .destructive:
                print("ADS")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    //resets the form
    @IBAction func resetForm(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FormTableController")
        var viewcontrollers = self.navigationController?.viewControllers
        viewcontrollers?.removeLast()
        viewcontrollers?.append(vc)
        self.navigationController?.setViewControllers(viewcontrollers!, animated: false)
    }
    
    //MARK: Animations
    var animationHappened = false
    var imageSet = false
    @IBOutlet weak var cameraButtonConstraint: NSLayoutConstraint!
    
    func performCameraAnimation(){
        guard  animationHappened == false else {return}
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseIn, animations: {
            self.cameraButtonConstraint.constant += self.view.bounds.width / 3
            self.view.layoutIfNeeded()
        }) { (_) in
            UIView.animate(withDuration: 0.6, delay: 0, options: .allowAnimatedContent, animations: {
                self.cameraImage.alpha = 1
            })}
        animationHappened = true
    }
}

//PickerView Extension /methods/
extension FormTableController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let category = categories[row]
        let myTitle = NSAttributedString(string: category, attributes: [NSAttributedStringKey.font: UIFont(name: "Futura", size: 15.0)!])
        return myTitle
    }
}

class ScaledHeightImageView: UIImageView {
    
    override var intrinsicContentSize: CGSize {
        
        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width
            
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio
            
            return CGSize(width: myViewWidth, height: scaledHeight)
        }
        
        return CGSize(width: -1.0, height: -1.0)
    }
}

//resizing images
//extension UIImage {
//    func resizeImage(newSize: CGSize) -> UIImage {
//        // Guard newSize is different
//        guard self.size != newSize else { return self }
//
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
//        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
//        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return newImage
//    }
//
//    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
//        let widthFactor = size.width / rectSize.width
//        let heightFactor = size.height / rectSize.height
//
//        var resizeFactor = widthFactor
//        if size.height > size.width {
//            resizeFactor = heightFactor
//        }
//
//        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
//        let resized = resizeImage(newSize: newSize)
//        return resized
//    }
//}


