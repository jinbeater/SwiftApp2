//
//  CommentViewController.swift
//  FireStoreStudy
//
//  Created by あかにしらぶお on 2021/09/11.
//

import UIKit
import Firebase
import FirebaseFirestore


class CommentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    

    var idString = String()
    
    var kaitouString = String()
    
    var userName = String()
    
    let db = Firestore.firestore()
    
    var dataSets = [CommentModel]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var kaitouLabel: UILabel!
    
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    //画面のサイズ
    let screenSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        kaitouLabel.text = kaitouString
        
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userName = UserDefaults.standard.object(forKey: "userName")as! String
        }
        
        //キーボードが出現した時のメソッドを呼び出し
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        //キーボードが消えた時のメソッドを呼び出し
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //キーボードが出現したときに viewを上げるメソッド
    @objc func keyboardWillShow(_ notification:NSNotification){
        
        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
        
        textField.frame.origin.y = screenSize.height - keyboardHeight - textField.frame.height
        sendButton.frame.origin.y = screenSize.height - keyboardHeight - sendButton.frame.height
        
        
    }
    
    //キーボードが消えたときに viewを戻すメソッド
    @objc func keyboardWillHide(_ notification:NSNotification){
        
        textField.frame.origin.y = screenSize.height - textField.frame.height
        
        sendButton.frame.origin.y = screenSize.height - sendButton.frame.height
        
        
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else{return}
        
        
        UIView.animate(withDuration: duration) {
            
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transform
            
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        
        loadData()
    }
    
    func loadData(){
        
        db.collection("Answers").document(idString).collection("comments").order(by: "postDate").addSnapshotListener { snapShot, error in
            
            self.dataSets = []
            if error != nil{
                return
            }
            
            if let snapShotDoc = snapShot?.documents{
                
                for doc in snapShotDoc{
                    
                    let data = doc.data()
                    if let userName = data["userName"] as?String,let comment = data["comment"] as? String,let postDate = data["postDate"] as? Double{
                        
                        //構造体のインスタンスの中にDBのデータを入れる
                        let commentModel = CommentModel(userName: userName, comment: comment, postDate: postDate)
                        
                        //構造体のインスタンスを配列に入れる
                        self.dataSets.append(commentModel)
                        
                    }
                }
                self.dataSets.reverse()
                self.tableView.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        tableView.rowHeight = 200
        
        let commentLabel = cell.contentView.viewWithTag(1) as! UILabel
        //ラベルのサイズを文字数によって可変にしたい
        commentLabel.numberOfLines = 0
        commentLabel.text = "\(self.dataSets[indexPath.row].userName)さん\n\(self.dataSets[indexPath.row].comment)"
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSets.count
    }
    
    //セルの高さを決めるメソッド
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 100
        return UITableView.automaticDimension
    }

    
    
    @IBAction func sendAction(_ sender: Any) {
        
        
        if textField.text?.isEmpty == true{
            return
        }
        
        //前の画面から値をもらったidString(ドキュメントID)に紐づけて新たなコレクションを作成している
        db.collection("Answers").document(idString).collection("comments").document().setData(["userName":userName as Any,"comment":textField.text as Any,"postDate":Date().timeIntervalSince1970
        ])
        
        textField.text = ""
        
        //キーボードを閉じる
        textField.resignFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
