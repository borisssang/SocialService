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
import KeychainAccess
import RZTransitions

class SignInController: UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
    
    @IBAction func presentSignInWindow(_ sender: UIButton) {
        self.transitioningDelegate = RZTransitionsManager.shared()
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController : LoginController = storyboard.instantiateViewController(withIdentifier: "login") as! LoginController
        nextViewController.transitioningDelegate = RZTransitionsManager.shared()
        self.present(nextViewController, animated:true) {}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RZTransitionsManager.shared().defaultPresentDismissAnimationController = RZZoomAlphaAnimationController()
        passwordTextField.delegate = self
        emailTextField.delegate = self
        setUpTextFieldsAndButtons()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
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
                
                self.saveUserIntoKeychain(name: name, password: password, email: email)
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func saveUserIntoKeychain(name: String, password: String, email: String){
        let keychain = Keychain(service: "https://firebase.google.com/")
        keychain[name] = password
        keychain["name"] = name
        keychain["password"] = password
        keychain["email"] = email
    }
    
    //signing in the user
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "showForm" {
            if let navVC = segue.destination as? UINavigationController{
                if let vc = navVC.topViewController as? FormTableController {
                    if passwordTextField.text != "" && emailTextField.text != "" {
                        guard isValidEmail(testStr: emailTextField.text!) else {showAlert(message: "Please enter a valid email address")
                            return}
                        Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (result, error) in
                            if error != nil {
                                print(error!)
                            }
                            else if let user = Auth.auth().currentUser {
                                let uid = user.uid
                                let db = Firestore.firestore()
                                db.collection("users").document(uid).getDocument(completion: { (snapshot, error) in
                                    
                                    let json = JSON(snapshot!)
                                    let name = json["name"].string!
                                    let password = json["id"].string!
                                    let email = json["email"].string!
                                    self.saveUserIntoKeychain(name: name, password: password, email: email)
                                })
                                print(user)
                            }
                        }
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
