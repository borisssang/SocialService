//
//  SignInController.swift
//  SocialServiceApp
//
//  Created by Boris Angelov on 21.08.18.
//  Copyright © 2018 Boris Angelov. All rights reserved.
//

import Foundation


import UIKit
import FBSDKLoginKit
import FBSDKShareKit
import Firebase
import FirebaseAuth
import SwiftyJSON
import JGProgressHUD
import FirebaseFirestore

class SignInController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        setUpTextFieldsAndButtons()
    }
    
    var dataForm: FormData?
    var user: UserEntity?
    
    //Outlets
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet weak var registerOutlet: UIButton!
    @IBOutlet weak var facebookRegisterOutlet: UIButton!
    
    @IBOutlet weak var goBack: UIButton!
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    func dismissHud(_ hud: JGProgressHUD, text: String, detailText: String, delay: TimeInterval) {
        hud.textLabel.text = text
        hud.detailTextLabel.text = detailText
        hud.dismiss(afterDelay: delay, animated: true)
    }
    
    //MARK: Registrations
    
    //FaceBookLoginButton
    @IBAction func LoginWithFacebookButton(_ sender: UIButton) {
        
        hud.textLabel.text = "Logging in with Facebook..."
        hud.show(in: view, animated: true)
        
        FBSDKLoginManager().logIn(withReadPermissions:["email", "public_profile"], from: self) { (result, err) in
            if err != nil{
                self.dismissHud(self.hud, text: "Error", detailText: "Failed to get Facebook user with error: \(err)", delay: 3)
                return
            }
            
            //getting FACEBOOK token + credentials
            let accessToken = FBSDKAccessToken.current()
            guard let accessTokenToString = accessToken?.tokenString else {return}
            
            //signing in into FIREBASE
            let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenToString)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    self.dismissHud(self.hud, text: "Sign in error", detailText: error.localizedDescription, delay: 3)
                    return
                }
                print("Auth successfull")
            }
            
            //Fetching the facebook user info
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
                
                let json = JSON(result!)
                let name = json["name"].string!
                let password = json["id"].string!
                let email = json["email"].string!
                
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc : UINavigationController = storyboard.instantiateViewController(withIdentifier: "navigation") as! UINavigationController
                if let formVC = vc.topViewController as? FormTableController{
                    
                    //KEYCHAIN NEEDED
                    formVC.user = self.user
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    //registering the user
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "showForm" {
            if let navVC = segue.destination as? UINavigationController{
                if let vc = navVC.topViewController as? FormTableController {
                    if  passwordTextField.text != "" && emailTextField.text != "" {
                        guard isValidEmail(testStr: emailTextField.text!) else {showAlert(message: "Please enter a valid email address")
                            return}
                        Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (result, error) in
                            if error != nil {
                                print(error!)
                            }
                            else if let user = Auth.auth().currentUser {
                                //TODO: get uiid + keychain
                                //search by uiid
                                //getting data and save it to user then pass it on
                                //KEYCHAIN
                                print(user)
                            }
                        }
//                        let user = UserEntity(first: firstNameTextField.text!, pas: passwordTextField.text!, email: emailTextField.text!, phone: Int(phoneTextField.text!)!)
                    }
                }
            }
        }
    }

    //email verification
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //alert if some of the fields are missing
    func showAlert(message: String){
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertControllerStyle.alert)
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
    
    //MARK: TEXTshit
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func setUpTextFieldsAndButtons(){
        
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.white.cgColor
        passwordTextField.layer.cornerRadius = 20
        passwordTextField.clipsToBounds = true
        
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.white.cgColor
        emailTextField.layer.cornerRadius = 20
        emailTextField.clipsToBounds = true
        
        registerOutlet.layer.cornerRadius = 20
        registerOutlet.clipsToBounds = true
        
        facebookRegisterOutlet.layer.cornerRadius = 20
        facebookRegisterOutlet.clipsToBounds = true
        
        goBack.layer.cornerRadius = 20
        goBack.clipsToBounds = true
    }
}
