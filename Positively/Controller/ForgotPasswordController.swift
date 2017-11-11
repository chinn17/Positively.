//
//  ForgotPasswordController.swift
//  Positively
//
//  Created by Chintan Puri on 08/10/17.
//  Copyright © 2017 Chintan Puri. All rights reserved.
//

import UIKit
import FirebaseAuth



class ForgotPasswordController: UIViewController {

    
    let backButton : UIButton = {
        let button = UIButton()
        
        button.setTitle("", for: UIControlState())
        button.setImage(#imageLiteral(resourceName: "backbtn"), for: UIControlState())
        button.tintColor = UIColor(displayP3Red: 255/255, green: 25/255, blue: 90/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.black, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(dismissForgotPasswordController), for: .touchUpInside)
        
        return button
        
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your email"
        tf.layer.masksToBounds = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
        
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let invalidEmailMessage : UILabel = {
       let label = UILabel()
        label.text = "Invalid Email"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        
        return label
        
    }()
    
    
    
    lazy var sendEmailButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(displayP3Red: 178/255, green: 57/255, blue: 67/255, alpha: 1)
        button.layer.cornerRadius = 16
        button.setTitle("Reset Password", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(sendPasswordResetLink), for: .touchUpInside)
        
        return button
    }()
    
    let instructionsLabel : UILabel = {
        let label = UILabel()
        label.text = "An email with instructions on how to reset your password will be sent shortly"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(r: 109, g: 109, b: 109)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
        
    }()
    
    let emailSentView : UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.isHidden = true
        return view
    }()
    
    let emailSentMessage : UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.text = "Password Reset Email Sent"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        return label
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupElements()
        setupEmailSentMessage()
    }

    func setupElements() {
        view.addSubview(backButton)
        view.addSubview(emailTextField)
        view.addSubview(emailSeparatorView)
        view.addSubview(invalidEmailMessage)
        view.addSubview(sendEmailButton)
        view.addSubview(instructionsLabel)
        
        backButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30).isActive = true
        backButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        
        emailTextField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        emailTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant : 50).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -40).isActive = true
        
        emailSeparatorView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
    
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -40).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        invalidEmailMessage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        invalidEmailMessage.topAnchor.constraint(equalTo: self.emailSeparatorView.bottomAnchor, constant: 20).isActive = true
        invalidEmailMessage.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7).isActive = true
        invalidEmailMessage.heightAnchor.constraint(equalTo: emailTextField.heightAnchor, multiplier: 1/2).isActive = true
   
    
        sendEmailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendEmailButton.topAnchor.constraint(equalTo: invalidEmailMessage.bottomAnchor, constant: 20).isActive = true
        sendEmailButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/2).isActive = true
        sendEmailButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        

        instructionsLabel.topAnchor.constraint(equalTo: self.sendEmailButton.bottomAnchor, constant: 20).isActive = true
        instructionsLabel.centerXAnchor.constraint(equalTo: sendEmailButton.centerXAnchor).isActive = true

        instructionsLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        instructionsLabel.heightAnchor.constraint(equalTo: emailTextField.heightAnchor, multiplier: 1/2).isActive = true
    }

    
    @objc func sendPasswordResetLink() {
        
        
        if (emailTextField.text?.isEmpty)! {
            self.invalidEmailMessage.text = "Please enter your email"
            self.invalidEmailMessage.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
                self.invalidEmailMessage.isHidden = true
                self.invalidEmailMessage.text = "Invalid Email"
            })
            
         return
        }
        
        
        if let email = emailTextField.text {

            Auth.auth().sendPasswordReset(withEmail: email, completion: { (err) in
                if err != nil {
                    self.invalidEmailMessage.isHidden = false
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
                        self.invalidEmailMessage.isHidden = true
                    })
                    return
                }
                self.showEmailSentMessage()
                
            })

        }
        
        
        
        
    }
    
    func setupEmailSentMessage() {
        
        view.addSubview(emailSentView)
        emailSentView.addSubview(emailSentMessage)
        self.emailSentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.emailSentView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
       self.emailSentView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -20).isActive = true
        self.emailSentView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/2).isActive = true
        self.emailSentView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        
        emailSentMessage.centerXAnchor.constraint(equalTo: self.emailSentView.centerXAnchor).isActive = true
        
        emailSentMessage.centerYAnchor.constraint(equalTo: self.emailSentView.centerYAnchor).isActive = true
        emailSentMessage.topAnchor.constraint(equalTo: self.emailSentView.topAnchor, constant: 30).isActive = true
        emailSentMessage.widthAnchor.constraint(equalTo: emailSentView.widthAnchor, multiplier: 0.8).isActive = true
        
        emailSentMessage.heightAnchor.constraint(equalToConstant: 90).isActive = true

     
        
    }
    
    func showEmailSentMessage() {
        let gradientLayer = CAGradientLayer()
        let startingColorGradient = UIColor(red: 189/255, green: 63/255, blue: 50/255, alpha: 1).cgColor
        let endingColorGradient = UIColor(red: 203/255, green: 53/255, blue: 107/255, alpha: 1).cgColor
        gradientLayer.frame = self.emailSentView.bounds
        gradientLayer.colors = [startingColorGradient,endingColorGradient]
        self.emailSentView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.emailSentView.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
         self.emailSentView.isHidden = true
         self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc func dismissForgotPasswordController() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
