//
//  AuthService.swift
//  breakpoint
//
//  Created by Kunal Tyagi on 26/01/18.
//  Copyright © 2018 Kunal Tyagi. All rights reserved.
//

import Foundation
import Firebase

class AuthService {
    static let instance = AuthService()
    
     func registerUser(withEmail email: String, andPassword password: String, completion: @escaping (_ status: Bool, _ error: Error?)-> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard let user = user else {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    
    func loginUser(withEmail email: String, andPassword password: String, completion: @escaping (_ status: Bool, _ error: Error?)-> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                completion(false, error)
            }
            else {
                completion(true, nil)
            }
        }
    }
}
