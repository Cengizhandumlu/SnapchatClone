//
//  UploadVC.swift
//  SnapchatClone
//
//  Created by Cengizhan DUMLU on 11.04.2021.
//

import UIKit
import Firebase
class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var uploadImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosenImage))
        uploadImageView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func choosenImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        uploadImageView.image = info[.originalImage] as? UIImage //original image ile degistir ve cast et
        self.dismiss(animated: true, completion: nil)
     }
    

    @IBAction func uploadClicked(_ sender: Any) {
        
        //Storage
        
        //ilk olarak storage kısmını halletmek gerekmekte
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        //görselleri nereye koyacagımızı karar verdigimiz klasör
        let mediaFolder = storageReference.child("media")
        
        //imageview alınıp dataya cevrilen kısım
        if let data = uploadImageView.image?.jpegData(compressionQuality: 0.5) {
            //görseli aldı ve veriye cevirdi
            //upload ettigimiz görsele isim vermemiz gerekiyor
            //bunun icin UUIDString kullanacagız
            let uuid = UUID().uuidString //rastgele bir deger aldık
            //depoya kaydetmek icin
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data, metadata: nil) { (metadata, error) in
                if error != nil {
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                }else{
                    imageReference.downloadURL { (url, error) in
                        if error == nil {
                            
                            
                            let imageUrl = url?.absoluteString
                            
                            
                            //FireStore
                            
                            //firestore kaydetme islemi
                            let fireStore = Firestore.firestore()
                            
                            //veri var mı yok mu kontrol etmek istiyoruz
                            fireStore.collection("Snaps").whereField("snapOwner", isEqualTo: UserSingleton.sharedUserInfo.username).getDocuments { (snapshot, error) in
                                if error != nil {
                                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                }else{
                                    //gercekten veri varsa eger
                                    if snapshot?.isEmpty == false && snapshot != nil{
                                        for document in snapshot!.documents {
                                            let documentId = document.documentID
                                            
                                            if var imageUrlArray = document.get("imageUrlArray") as? [String] {
                                                imageUrlArray.append(imageUrl!)
                                                
                                                //koymak istedigimiz data
                                                let additionalDictionary = ["imageUrlArray" : imageUrlArray] as [String : Any]
                                                
                                                //tekrar alıp firebase'e tekrar kaydedecegim
                                                fireStore.collection("Snaps").document(documentId).setData(additionalDictionary, merge: true) { (error) in
                                                    if error != nil {
                                                        self.tabBarController?.selectedIndex = 0
                                                        self.uploadImageView.image = UIImage(named: "selectimage.png")
                                                    }
                                                }
                                            }else{
                                                
                                            }
                                        }
                                    }else {
                                        //Kaydetme işlemi
                                        
                                        let snapDictionary = ["imageUrlArray" : [imageUrl!], "snapOwner": UserSingleton.sharedUserInfo.username, "date":FieldValue.serverTimestamp()] as [String : Any]
                                        fireStore.collection("Snaps").addDocument(data: snapDictionary) { (error) in
                                            if error != nil {
                                                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                            }else{
                                                self.tabBarController?.selectedIndex = 0
                                                self.uploadImageView.image = UIImage(named: "selectimage.png")
                                            }
                                        }
                                    }
                                }
                            }
                            

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
    
}
