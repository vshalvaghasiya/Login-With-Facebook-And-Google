//
//  SocialLoginViewController.swift
//  SocialIntegration
//
//  Created by vishal on 06/12/17.
//  Copyright © 2017 vishal. All rights reserved.
//

import UIKit
import FBSDKShareKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
class SocialLoginViewController: UIViewController , GIDSignInUIDelegate, GIDSignInDelegate{

    //Facebook Login Related
    var userResults:[String:AnyObject] = [:]
    var email:String = ""
    var name:String = ""
    var email1:String = ""
    var facebookID:String = ""
    //END
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Facebook Login
    @IBAction func facebookLoginButtonClick(_ sender: UIButton) {
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbLoginResult: FBSDKLoginManagerLoginResult = result!
                if fbLoginResult.grantedPermissions != nil {
                    if(fbLoginResult.grantedPermissions.contains("email")){
                        self.facebookLogin()
                    }
                }
            }
            else{
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    func facebookLogin() {
        if((FBSDKAccessToken.current()) != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, first_name, last_name, picture.type(large), email "]).start(completionHandler: { (connection, result, error) in
                if result == nil {
                    print(error?.localizedDescription ?? "")
                }
                else{
                    self.userResults = result as! [String : AnyObject]
                    self.email = (self.userResults["email"] as? String) ?? ""
                    self.facebookID = (self.userResults["id"] as? String) ?? ""
                    if (self.facebookID != "") {
                        self.userResults = result as! [String : AnyObject]
                        print("Login Success",self.userResults)
                        self.name = (self.userResults["name"] as? String) ?? ""
                        self.email1 = (self.userResults["email"] as? String) ?? ""
                        
                        let url = URL(string: "http://graph.facebook.com/\(self.facebookID)/picture?type=large")!
                        let session = URLSession(configuration: .default)
                        let downloadPicTask = session.dataTask(with: url) { (data, response, error) in
                            // The download has finished.
                            if let e = error {
                                print(e.localizedDescription)
                            } else {
                                if let res = response as? HTTPURLResponse {
                                    print(res.statusCode)
                                    if let imageData = data {
                                        let _: UIImage = UIImage(data: imageData)!
                                    } else {
                                        print("Couldn't get image: Image is nil")
                                    }
                                } else {
                                   print("Couldn't get response code for some reason")
                                }
                            }
                        }
                        downloadPicTask.resume()
                    }
                    else if error != nil {
                        print(error?.localizedDescription ?? "")
                    }
                    else{
                        print(error?.localizedDescription ?? "")
                    }
                }
            })
        }
    }
    
    //MARK:- Google Login
    @IBAction func googleLoginButtonClick(_ sender: UIButton) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        let user = GIDSignIn.sharedInstance().currentUser
        print(user?.userID ?? "")
        print(user?.profile.givenName ?? "")
        print(user?.profile.familyName ?? "")
        if (user?.profile.hasImage)! == true {
            print(user!.profile.imageURL(withDimension: 100).absoluteURL)
        }
    }
    
}

