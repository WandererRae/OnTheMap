//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Bogue Shannon on 4/19/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - Storyboard
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var noAccountSignUpLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        displayErrorMessage(false, nil)
    }
    
    // MARK: - Login to Udacity
    
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        errorMessageLabel.isHidden = true
        requestInProgress()
        
        sendLoginRequest()
           }

    // MARK: - Udacity login steps
    
    func sendLoginRequest () {
        UdacityClient.shared().send (request: UdacityClient.shared().loginRequest( username: emailTextField.text!, password: passwordTextField.text!)
        ) { data, error in
            guard error == nil else {
                self.requestFinished()
                self.displayErrorMessage(true, error)
                return
            }
            guard data != nil else {
                self.requestFinished()
                self.displayErrorMessage(true, "Nil login request data")
                return
            }
            self.processLoginResponse(data!)
        }
    }
    
    func processLoginResponse (_ data: Data) {
        UdacityClient.shared().decodeLoginData(data) { sessionInfo, error in
            guard error == nil else {
                self.requestFinished()
                self.displayErrorMessage(true, error)
                return
            }
            guard let validSession = sessionInfo else {
                self.requestFinished()
                self.displayErrorMessage(true, "Invalid session info")
                return
            }
            UdacityClient.shared().sessionInfo = validSession
            self.getUserData(validSession.userId)
        }
    }
    
    func getUserData (_ userKey: String) {
        UdacityClient.shared().send(request:
            UdacityClient.shared().userDataRequest(userKey)) { data, error in
                guard error == nil else {
                    self.requestFinished()
                    self.displayErrorMessage(true, error)
                    return
                }
                guard let validData = data else {
                    self.requestFinished()
                    self.displayErrorMessage(true, "Could not find user location parse data")
                    return
                }
                self.saveUserInfo(validData)
        }
    }
    
    func saveUserInfo (_ data: Data) {
        UdacityClient.shared().decodeUserData(data) { userInfo, error in
            guard error == nil else {
                self.requestFinished()
                self.displayErrorMessage(true, error)
                return
            }
            guard let validUserInfo = userInfo else {
                self.requestFinished()
                self.displayErrorMessage(true, "Could not save user info")
                return
            }
            UdacityClient.shared().userInfo = validUserInfo
            self.getUserLocations(validUserInfo.parseUniqueKey)
        }
    }
    
    func getUserLocations (_ userKey: String) {
        ParseClient.shared().request(
            ParseClient.shared().get(
                ParseClient.shared().userLocations(key: userKey))) { data, error in
                    guard error == nil else {
                        self.requestFinished()
                        self.displayErrorMessage(true, error)
                        return
                    }
                    guard let validData = data else {
                        self.requestFinished()
                        self.displayErrorMessage(true, "Could not find user location parse data")
                        return
                    }
                    self.saveUserLocation(validData)
        }
    }

    func saveUserLocation (_ data: Data) {
        ParseClient.shared().convertGetResponseDataToLocationEntries(data) { entries, error in
            guard error == nil else {
                self.requestFinished()
                self.displayErrorMessage(true, error)
                return
            }
            guard entries != nil else {
                self.requestFinished()
                self.displayErrorMessage(true, "Nil entries")
                return
            }
            if let userLocation = entries!.first {
                StudentLocations.shared().forUser = userLocation
                self.requestFinished()
                self.loginComplete()
            } else {
                self.requestFinished()
                self.loginComplete()
            }
        }
    }
    

    
    // MARK: - Helper functions
    
    private func loginComplete () {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "successfulLoginSegue", sender: nil)
        }
    }
    
    private func displayErrorMessage(_ bool: Bool, _ message: String?) {
        DispatchQueue.main.async {
            self.errorMessageLabel.text = message ?? ""
            self.errorMessageLabel.isHidden = !bool
        }
    }
    
    private func requestInProgress () {
        DispatchQueue.main.async {
            self.showLoadingSpinner(true)
            self.logInButton.isEnabled = false
        }
    }
    
    private func requestFinished () {
        DispatchQueue.main.async {
            self.showLoadingSpinner(false)
            self.logInButton.isEnabled = true
        }
    }
    
    
    // MARK: - Sign up for Udacity
    
    @IBAction func signUp(_ sender: UIButton) {
        let app = UIApplication.shared
        if let url = URL(string: "https://auth.udacity.com/sign-up") {
            app.open(url)
        }
    }
}

