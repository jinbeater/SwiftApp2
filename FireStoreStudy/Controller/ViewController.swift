//
//  ViewController.swift
//  FireStoreStudy
//
//  Created by あかにしらぶお on 2021/09/03.
//

import UIKit
import Firebase
import FirebaseFirestore
import EMAlertController
import FirebaseAuth


class ViewController: UIViewController {

    
    //DBの場所を指定する
    let db1 = Firestore.firestore().collection("odai").document("ur2rrRsZPu6f9vc4wTQb")
    
    let db2 = Firestore.firestore()
    
    var userName = String()
    
    
    @IBOutlet weak var odaiLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    var idString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //もしアプリ内にユーザー名が保存されていれば、変数にそのユーザ名を入れる
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userName = UserDefaults.standard.object(forKey: "userName")as! String
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.object(forKey: "documentID") != nil{
            
            idString = UserDefaults.standard.object(forKey: "documentID")as! String
            
        }else{
            
            //idStringには、Answers/ngowgnoiwenoweのような文字列が入る
            //このソースコードで同時にドキュメントIDを発行している
            idString = db2.collection("Answers").document().path
            //idStringの最初の８文字を削ってドキュメントIDだけにしている
            idString = String(idString.dropFirst(8))
            UserDefaults.standard.setValue(idString, forKey: "documentID")
        }
        
        
        
        self.navigationController?.isNavigationBarHidden = true
        
        //ロード
        loadQuestionData()
        
    }
    
    
    func loadQuestionData()  {
        
        db1.getDocument { snapShot, error in
            if error != nil{
                return
            }
            //ドキュメント内に入っているデータをとってくる。つまりすべてのデータ
            let data = snapShot?.data()
            
            //DB内のフィールド名を指定して値を取得し、ラベルに代入
            self.odaiLabel.text = data!["odaiText"] as? String

        }
        
    }

    
    @IBAction func send(_ sender: Any) {
        
        //firestoreにコレクションを作成して同時にフィールドも作成できる
        //db2.collection("Answers").document().setData(["Answer" : textView.text as Any ,"userName":userName,"postDate":Date().timeIntervalSince1970])
        db2.collection("Answers").document(idString).setData(["Answer" : textView.text as Any ,"userName":userName,"postDate":Date().timeIntervalSince1970,"like":0,"likeFlagDic":[idString:false]])
        
        //テキストフィールドを空にする
        textView.text = ""
        
        //アラート
        let alert = EMAlertController(icon: UIImage(named: "check"), title: "投稿完了！", message: "みんなの回答を見てみよう！")
        let doneAction = EMAlertAction(title: "OK", style: .normal)
        alert.addAction(doneAction)
        present(alert, animated: true, completion: nil)

    }
    
    
    
    @IBAction func checkAnswer(_ sender: Any) {
        
        let checkVC = storyboard?.instantiateViewController(identifier: "checkVC") as! CheckViewController
        
        checkVC.odaiString = odaiLabel.text!
        
        navigationController?.pushViewController(checkVC, animated: true)
    }
    
    
    @IBAction func logout(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "documentID")
            
        } catch let error as NSError {
            print("エラー",error)
        }
        
        //ログアウト後にログイン画面に遷移するコード
       // self.navigationController?.popViewController(animated: true)
        //let targetVC = navigationController?.viewControllers[0] ?? UIViewController()
        //navigationController?.popToViewController(targetVC, animated: true)
        
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        navigationController?.pushViewController(loginVC, animated: true)
        
    }
    
}

