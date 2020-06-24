//
//  EmailSignUpViewController.swift
//  Noted
//
//  Created by Kedar Abhyankar on 6/21/20.
//  Copyright © 2020 Kedar Abhyankar. All rights reserved.
//

import UIKit
import BRYXBanner
import FirebaseAuth

class EmailSignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    final let ui_red: UIColor = UIColor(red: 255.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.000)
    final let ui_blue: UIColor = UIColor(red: 0.0/255.0, green: 0/255.0, blue: 255.0/255.0, alpha: 1.000)
    final let ui_green: UIColor = UIColor(red: 0.0/255.0, green: 255.0/255.0, blue: 0/255.0, alpha: 1.000)
    final let ui_yellow: UIColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 0/255.0, alpha: 1.000)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onCompleteSignUpFlow(_ sender: Any) {
        
        let firstNameFailBanner = Banner(title: "Invalid First Name!", subtitle: "Your first name can only contain letters, and the field must not be left empty!", image: nil, backgroundColor: ui_red, didTapBlock: nil)
        let lastNameFailBanner = Banner(title: "Invalid Last Name!", subtitle: "Your last name can only contain letters, and the field must not be left empty!", image: nil, backgroundColor: ui_red, didTapBlock: nil)
        let emailFailBanner = Banner(title: "Invalid email!", subtitle: "Your email must of valid formatting!", image: nil, backgroundColor: ui_red, didTapBlock: nil)
        var passFailBanner = Banner(title: "Invalid password!", subtitle: "Your password must have at least two uppercase letters, one special character, two digits, three lowercase letters, and be of minimum length of 8!", image: nil, backgroundColor: ui_red, didTapBlock: nil)
        let passMatchFailBanner = Banner(title: "Your passwords don't match!", subtitle: "Your passwords don't match!", image: nil, backgroundColor: ui_red, didTapBlock: nil)
        
        
        let firstName:String = firstNameField.text ?? ""
        let lastName:String = lastNameField.text ?? ""
        let emailAddress:String = emailAddressField.text ?? ""
        let password:String = passwordField.text ?? ""
        let confirmPassword:String = confirmPasswordField.text ?? ""
        
        let validFirst = validateName(name: firstName);
        let validLast = validateName(name: lastName);
        let validEmail = validateEmail(email : emailAddress);
        let validPass = validatePass(pass: password);
        let matchingPass = matchPass(pass: password, confirmPass: confirmPassword);
        let delayInSec = 2.0;
        
        if(!validFirst){
            firstNameFailBanner.show(nil, duration: 1.5)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSec){
            if(!validLast){
                lastNameFailBanner.show(nil, duration: 1.5)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (delayInSec * 2)){
            if(!validEmail){
                emailFailBanner.show(nil, duration: 1.5)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (delayInSec * 3)){
            if(!validPass.0) {
                
                if(validPass.1 == "length"){
                    passFailBanner = self.passFailBannerBuilder(text: "Your password is too short!")
                } else if(validPass.1 == "upper"){
                    passFailBanner = self.passFailBannerBuilder(text: "You must have a minimum of two upper case characters!");
                } else if(validPass.1 == "lower"){
                    passFailBanner = self.passFailBannerBuilder(text: "You must have a minimum of minimum of three upper case characters!");
                } else if(validPass.1 == "number"){
                    passFailBanner = self.passFailBannerBuilder(text: "You must have a minimum of two numbers!")
                } else if(validPass.1 == "special"){
                    passFailBanner = self.passFailBannerBuilder(text: "You must have a minimum of one special character!")
                }
                passFailBanner.show(nil, duration: 2.0)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (delayInSec * 4)){
            if(!matchingPass){
                passMatchFailBanner.show(nil, duration: 1.5)
            }
        }
        
        if(validFirst && validLast && validEmail && validPass.0 && matchingPass){
            Auth.auth().createUser(withEmail: emailAddress, password: password){ (authResult, error) in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    print("Successful Signup!")
                    
                }
            }
        }
    }
    
    func validateName(name: String) -> Bool {
        return (!name.isEmpty && (name.range(of: "[^a-zA-Z]") != nil))
    }
    
    func validateEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePass(pass: String) -> (Bool, String) {
        if(pass.count < 8){
            return (false, "length")
        }
        var upper, lower, special, num: Int;
        upper = 0
        lower = 0
        special = 0
        num = 0
        for char in pass{
            if(char.isUppercase){
                upper += 1
            } else if(char.isLowercase){
                lower += 1
            } else if(char.isSymbol){
                special += 1
            } else if(char.isNumber){
                num += 1
            }
        }
        
        if(upper < 2){
            return (false, "upper")
        }
        if(lower < 3){
            return (false, "lower")
        }
        if(num < 2){
            return (false, "number")
        }
        if(special < 1){
            return (false, "special")
        }
        return (true, "")
    }
    
    func matchPass(pass: String, confirmPass: String) -> Bool {
        return pass == confirmPass
    }
    
    func passFailBannerBuilder(text: String) -> Banner {
        return Banner(title: "Invalid Password!", subtitle: text, image: nil, backgroundColor: ui_yellow, didTapBlock: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
