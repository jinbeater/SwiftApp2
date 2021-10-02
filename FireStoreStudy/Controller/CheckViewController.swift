//
//  CheckViewController.swift
//  FireStoreStudy
//
//  Created by あかにしらぶお on 2021/09/07.
//

import UIKit
import Firebase
import FirebaseFirestore


class CheckViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    

    var odaiString = String()
    
    @IBOutlet weak var odaiLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    var dataSets = [AnswersModel]()
    var idString = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        odaiLabel.text = odaiString
        tableView.delegate = self
        tableView.dataSource = self
        
        //カスタムセルにアクセスするためのコード
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        if UserDefaults.standard.object(forKey: "documentID") != nil{
            idString = UserDefaults.standard.object(forKey: "documentID") as! String
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSets.count
    }
    
    //セルの情報を更新するメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        tableView.rowHeight = 200
        cell.answerLabel.numberOfLines = 0
        cell.answerLabel.text = "\(self.dataSets[indexPath.row].userName)さんの回答\n\(self.dataSets[indexPath.row].answers)"
        cell.likeButton.tag = indexPath.row
        cell.countLabel.text = String(self.dataSets[indexPath.row].likeCount) + "いいね"
        cell.likeButton.addTarget(self, action: #selector(like(_:)), for: .touchUpInside)
        print(cell.countLabel.text as Any)
        //ライクフラッグに自分のIDが存在すれば、つまり自分がライクボタンを押した履歴があれば
        if(self.dataSets[indexPath.row].likeFlagDic[idString] != nil) == true {
            let flag = self.dataSets[indexPath.row].likeFlagDic[idString]
            
            if flag! as! Bool == true {
                
                cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
            }else{
                cell.likeButton.setImage(UIImage(named: "notlike"), for: .normal)
                
            }
            
        }
        
        
//       let answerLabel = cell.contentView.viewWithTag(1) as!UILabel
        //これでラベルの表示行数がが可変になる
//        answerLabel.numberOfLines = 0
//        answerLabel.text = "\(self.dataSets[indexPath.row].userName)さんの回答\n\(self.dataSets[indexPath.row].answers)"
//
//        cell.selectionStyle = .none
        
        return cell
        
    }
    
    //セルのライクボタンが押された時のメソッド
    @objc func like(_ sender:UIButton){
        
        
        var count = Int()
        //answerの中のライクフラグの自分のIDを指定している
        let flag = self.dataSets[sender.tag].likeFlagDic[idString]
        
        if flag == nil {
            count = self.dataSets[sender.tag].likeCount + 1
            db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic":[idString:true]], merge: true)
        }else{
            if flag! as! Bool == true{
                count = self.dataSets[sender.tag].likeCount - 1
                db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic":[idString:false]], merge: true)
            }else{
                count = self.dataSets[sender.tag].likeCount + 1
                db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic":[idString:true]], merge: true)
            }
        }
        //countの情報を送信する
        db.collection("Answers").document(dataSets[sender.tag].docID).updateData(["like":count], completion: nil)
        tableView.reloadData()
        
    }
    
    //セルの高さを決めるメソッド
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 100
        return UITableView.automaticDimension
    }
    
    //セルが選択されたとき
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //画面遷移
        let commentVC = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! CommentViewController
        
        commentVC.idString = dataSets[indexPath.row].docID
        commentVC.kaitouString = "\(dataSets[indexPath.row].userName)さんの回答\n\(dataSets[indexPath.row].answers)"
        
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    //firestoreからAnswerModelに必要なデータを持ってくる
    func loadData() {
        //Answers(コレクション)のdocument達を日付の新しい順に引っ張ってくる
        
        //dataSetsに入れるAnswersModel型として
        
        db.collection("Answers").order(by: "postDate").addSnapshotListener { snapShot, error in
            
            self.dataSets = []
            
            if error != nil{
                return
            }
            
            //もしドキュメントが空でなければ
            if let snapShotDog = snapShot?.documents{
                //コレクション内のドキュメントの数だけループ
                for doc in snapShotDog{
                    
                    let data = doc.data()
                    if let answer = data["Answer"]as? String,let userName = data["userName"] as? String,let likeCount = data["like"] as? Int,let likeFlagDic = data["likeFlagDic"] as? Dictionary<String,Bool>{
                        
                        //likeFlagDicのドキュメントIDが存在していれば(一番初めのドキュメントIDがない場合を想定)
                        if likeFlagDic["\(doc.documentID)"] != nil{
                            
                            let answerModel = AnswersModel(answers: answer, userName: userName, docID: doc.documentID, likeCount: likeCount, likeFlagDic: likeFlagDic)
                            
                            self.dataSets.append(answerModel)
                        }
                        
                        //                        //AnswerModelという構造体の中にデータベースのデータを代入している
                        //                        let answerModel = AnswersModel(answers: answer, userName: userName, docID: doc.documentID)
                        
                        
                    }
                }
                
                //                //配列の順番を逆転させる
                //                self.dataSets.reverse()
                
                self.tableView.reloadData()
            }
            
        }
        
        
    }



}
