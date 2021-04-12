//
//  FeedVC.swift
//  SnapchatClone
//
//  Created by Cengizhan DUMLU on 11.04.2021.
//

import UIKit
import Firebase
import SDWebImage


class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let fireStoreDatabase = Firestore.firestore()
    var snapArray = [Snap]()
    var chosenSnap : Snap? //optional olarak belirlendi
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getSnapsFromFirebase()
        
        getUserInfo()
        
    }
    
    func getSnapsFromFirebase(){
        //verileri cekecegiz(Firestoredan)
        //tarihe göre verileri cekip en yeniden en eskiye dogru sıraladık
        fireStoreDatabase.collection("Snaps").order(by: "date", descending: true).addSnapshotListener { (snapshot, error) in
            if error != nil {
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            }else{
                if snapshot?.isEmpty == false && snapshot != nil {
                    self.snapArray.removeAll(keepingCapacity: false) //forloop öncesi snapArray temizleme islemi yapıldı
                    for document in snapshot!.documents {
                        
                        let documentId = document.documentID
                        
                        if let username = document.get("snapOwner") as? String {
                            if let imageUrlArray = document.get("imageUrlArray") as? [String] {
                                if let date = document.get("date") as? Timestamp {
                                    
                                    if let difference = Calendar.current.dateComponents([.hour], from: date.dateValue(), to: Date()).hour {
                                        //kaydedilen date.datevalue - güncel zaman, zaman farkını söylüyor.
                                        if difference >= 24 {
                                            //Delete from firebase
                                            self.fireStoreDatabase.collection("Snaps").document(documentId).delete { (error) in
                                                
                                            }
                                        }else{
                                        
                                        //TIMELEFT -> SNAPVC
                                        //self.timeLeft = 24 - difference //24 saatten zamanımızı cıkardık.
                                        let snap = Snap(username: username, imageUrlArray: imageUrlArray, date: date.dateValue(), timeDifference: 24 - difference)
                                        self.snapArray.append(snap)
                                        
                                        
                                    }
                                }
                                    
                                    
                            }
                        }
                        
                    }
                }
                    self.tableView.reloadData() //önemli
            }
        }
        
    }
}
    func getUserInfo(){
        
        fireStoreDatabase.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { (snapshot, error) in
            if error != nil {
                
            }else{
                if snapshot?.isEmpty == false && snapshot != nil {
                    for document in snapshot!.documents {
                        if let username = document.get("username") as? String { //veri tabanında username kısmını alıyoruz.
                            //aktarmak icin singleton yapısını kullanacagız
                            UserSingleton.sharedUserInfo.email = Auth.auth().currentUser!.email!
                            UserSingleton.sharedUserInfo.username = username
                            //bu sayede veri tabanından alınan username ve email bilgilerini uploadVC kısmında cekip kullanabilecegim.
                            
                        }
                    }
                }
            }
        }
        
    }
        
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.feedUsernameLabel.text = snapArray[indexPath.row].username
        cell.feedImageView.sd_setImage(with: URL(string: snapArray[indexPath.row].imageUrlArray[0]))
        return cell
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSnapVC" {
            
            let destinationVC = segue.destination as! SnapVC
            destinationVC.selectedSnap = chosenSnap //degerleri SnapVCye aktarma islemi yaptık
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        chosenSnap = self.snapArray[indexPath.row]
        
        performSegue(withIdentifier: "toSnapVC", sender: nil)
    }
}

