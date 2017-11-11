//
//  Handlers.swift
//  Positively
//
//  Created by Chintan Puri on 08/10/17.
//  Copyright © 2017 Chintan Puri. All rights reserved.
//


import UIKit
import Firebase

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   @objc func handleRegister() {
        
        
    if (!self.isInternetConnected) {
        return
    }
        
        if (emailTextField.text == "" || nameTextField.text == "" || passwordTextField.text == "" || confirmPasswordTextField.text == "") {
            
            self.passwordsDoNotMatchMessage.text = "Please Fill All the Fields"
            self.passwordsDoNotMatchMessage.isHidden = false
            
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(passwordsMismatch), userInfo: nil, repeats: false)
            
            
            return
        }
        
        if((passwordTextField.text?.count)! < 6 || (confirmPasswordTextField.text?.count)! < 6) {
            self.passwordsDoNotMatchMessage.text = "Password must be atleast 6 characters long"
            self.passwordsDoNotMatchMessage.isHidden = false
            
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(passwordsMismatch), userInfo: nil, repeats: false)
            
            
            return
            
        }
        
        if (passwordTextField.text! != confirmPasswordTextField.text!) {
            self.passwordsDoNotMatchMessage.text = "Passwords Do Not Match"
            self.passwordsDoNotMatchMessage.isHidden = false
            
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(passwordsMismatch), userInfo: nil, repeats: false)
            
            
            return
        }
        
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
    

    
    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
        let gradientLayer = CAGradientLayer()
        let startingColorGradient = UIColor(red: 255/255, green: 195/255, blue: 113/255, alpha: 1).cgColor
        let endingColorGradient = UIColor(red: 255/255, green: 95/255, blue: 109/255, alpha: 1).cgColor
        gradientLayer.frame = self.accountCreatedView.bounds
        gradientLayer.colors = [startingColorGradient,endingColorGradient]
        self.accountCreatedView.layer.insertSublayer(gradientLayer, at: 0)
        self.accountCreatedView.isHidden = false
        self.privacyPolicy.isHidden = true

            //successfully authenticated user
            let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
            
//            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
            
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl,"friends" : ["No Friends":1]] as [String : Any]
                        
                        self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                    }
                })
            }
        })
            
            
        
            
            
    }
    
    
    @objc func passwordsMismatch() {
        self.passwordsDoNotMatchMessage.isHidden = true
        
    }
    
    
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                return
            }
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.dismissSignUpController), userInfo: nil, repeats: false)
            
            
        })
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.tapToAddLabel.isHidden = true
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled picker")
        dismiss(animated: true, completion: nil)
    }
    
}

