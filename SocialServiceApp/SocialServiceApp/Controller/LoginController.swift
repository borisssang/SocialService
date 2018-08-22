//
//  LoginController.swift
//  Фандъкова
//
//  Created by Boris Angelov on 14.08.18.
//  Copyright © 2018 Melon. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKShareKit
import Firebase
import FirebaseAuth
import SwiftyJSON
import JGProgressHUD
import FirebaseFirestore

class LoginController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        setUpTextFieldsAndButtons()
    }

    var dataForm: FormData?
    var user: UserEntity?
    
    //Outlets
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet weak var registerOutlet: UIButton!
    @IBOutlet weak var facebookRegisterOutlet: UIButton!
    
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
            
            //signing up into FIREBASE
            let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenToString)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    self.dismissHud(self.hud, text: "Sign up error", detailText: error.localizedDescription, delay: 3)
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
                self.user = UserEntity(first: name, pas: password, email: email, phone: 0)
                self.saveUserIntoFirebaseDatabase()
                
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc : UINavigationController = storyboard.instantiateViewController(withIdentifier: "navigation") as! UINavigationController
                if let formVC = vc.topViewController as? FormTableController{
                    formVC.user = self.user
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    //storing user info into firestore
    func saveUserIntoFirebaseDatabase() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { dismissHud(self.hud, text: "Error", detailText: "Failed to save user.", delay: 3); return }
        
        let dictionaryValues: [String : Any] = ["email": user?.userEmail ?? "",
                                "name": user?.name ?? "",
                                "password": user?.password ?? "",
                                "phone": user?.userPhone ?? ""]
        db.collection("users").document(uid).setData(dictionaryValues)
    }
    
    //user presses REGISTER
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "showForm" {
            if let navVC = segue.destination as? UINavigationController{
                if let vc = navVC.topViewController as? FormTableController {
                    //validation
                    if phoneTextField.text != "" && firstNameTextField.text != "" && passwordTextField.text != "" && emailTextField.text != "" {
                        guard (phoneTextField.text?.isNumber)! else {showAlert(message: "Please enter a valid phone number")
                            return}
                        guard isValidEmail(testStr: emailTextField.text!) else {showAlert(message: "Please enter a valid email address")
                            return}
                        //creating the user
                        let currentUser = UserEntity(first: firstNameTextField.text!, pas: passwordTextField.text!, email: emailTextField.text!, phone: Int(phoneTextField.text!)!)
                        self.user = currentUser
                //registering the user into Firestore
                        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
                            guard (authResult?.user) != nil else { return }
                        }
                        //KEYCHAIN NEEDED
                        saveUserIntoFirebaseDatabase()
                        vc.user = currentUser
                    }
                    else{
                        showAlert(message: "Make sure you have provided all the information required")
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
        
        firstNameTextField.layer.borderWidth = 1
        firstNameTextField.layer.borderColor = UIColor.white.cgColor
        firstNameTextField.layer.cornerRadius = 20
        firstNameTextField.clipsToBounds = true
        
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.white.cgColor
        passwordTextField.layer.cornerRadius = 20
        passwordTextField.clipsToBounds = true
        
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.white.cgColor
        emailTextField.layer.cornerRadius = 20
        emailTextField.clipsToBounds = true
        
        phoneTextField.layer.borderWidth = 1
        phoneTextField.layer.borderColor = UIColor.white.cgColor
        phoneTextField.layer.cornerRadius = 20
        phoneTextField.clipsToBounds = true
        
        registerOutlet.layer.cornerRadius = 20
        registerOutlet.clipsToBounds = true
        
        facebookRegisterOutlet.layer.cornerRadius = 20
        facebookRegisterOutlet.clipsToBounds = true
    }
}
extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

