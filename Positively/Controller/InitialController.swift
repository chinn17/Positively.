//
//  Initial.swift
//  Positively
//
//  Created by Chintan Puri on 08/10/17.
//  Copyright © 2017 Chintan Puri. All rights reserved.
//


import UIKit


class InitialController: UIViewController, UINavigationControllerDelegate {
    
    var messagesController : MessagesController?
    let gradientLayer = CAGradientLayer()
    let logoImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    
    let positivelyLabel : UILabel = {
        let label = UILabel()
        
        
        label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 45)
        label.adjustsFontSizeToFitWidth = true
        
        label.text = "positively"
        
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 20
        button.setTitle("LOGIN", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        button.setTitleColor(UIColor(red: 255/255, green: 132/255, blue: 71/255, alpha: 1), for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(openLogin), for: .touchUpInside)
        
        return button
    }()
    
    lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 20
        button.setTitle("SIGN UP", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(red: 255/255, green: 132/255, blue: 71/255, alpha: 1), for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(openSignUp), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        view.backgroundColor = UIColor.white
        view.addSubview(logoImageView)
        view.addSubview(positivelyLabel)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        
        setupLogoAndBackground()
        
    }
    
    
    func setupLogoAndBackground() {
        self.view.addSubview(self.logoImageView)
        
        
        let startingColorGradient = UIColor(red: 255/255, green: 95/255, blue: 109/255, alpha: 1).cgColor
        let endingColorGradient = UIColor(displayP3Red: 253/255, green: 231/255, blue: 155/255, alpha: 1).cgColor
        self.gradientLayer.colors = [startingColorGradient , endingColorGradient]
        
        
        self.gradientLayer.frame = view.bounds
        
        view.layer.insertSublayer(self.gradientLayer, at: 0)
        
        
        logoImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        logoImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/2).isActive = true
        logoImageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.28).isActive = true
        
        
        logoImageView.bottomAnchor.constraint(equalTo: positivelyLabel.topAnchor).isActive = true
        
        positivelyLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor).isActive = true
        positivelyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        positivelyLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        positivelyLabel.widthAnchor.constraint(equalTo: logoImageView.widthAnchor).isActive = true
        positivelyLabel.heightAnchor.constraint(equalTo: logoImageView.heightAnchor, multiplier : 1/2).isActive = true
        
        
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        loginButton.topAnchor.constraint(equalTo: positivelyLabel.bottomAnchor, constant: 75).isActive = true
        loginButton.widthAnchor.constraint(equalTo: positivelyLabel.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.bottomAnchor.constraint(equalTo: self.signUpButton.topAnchor, constant : -20).isActive = true
        
        signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor).isActive = true
        
        signUpButton.widthAnchor.constraint(equalTo: positivelyLabel.widthAnchor).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        signUpButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
        
    }
    
    @objc func openSignUp() {
        
        let signUpController = SignUpViewController()
        
        
        let navController = UINavigationController(rootViewController: signUpController)
        self.present(navController, animated: true, completion: nil)
        
        //        self.present(signUpController, animated: true, completion: nil)
        
        
        
    }
    
    @objc func openLogin() {
        
        let loginController = LoginController()
        
        
        self.present(loginController, animated: true, completion: nil)
        
        
        
    }
    
    
    
    
    
    
}
