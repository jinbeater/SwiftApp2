//
//  LoginViewController.swift
//  FireStoreStudy
//
//  Created by あかにしらぶお on 2021/09/03.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    
    
    @IBOutlet weak var textField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }

    func login(){
        
        //firestoreと通信を行う
        Auth.auth().signInAnonymously { result, error in
            let user = result?.user
            print(user)
            
            //テキストに入力されたユーザー名をアプリ内に保存する
            UserDefaults.standard.set(self.textField.text, forKey: "userName")
            
            //画面遷移
            let viewVC = self.storyboard?.instantiateViewController(identifier: "viewVC")as! ViewController
            
            self.navigationController?.pushViewController(viewVC, animated: true)
        }
        
    }
    
    @IBAction func done(_ sender: Any) {
        
        login()
    }
    
    
}
