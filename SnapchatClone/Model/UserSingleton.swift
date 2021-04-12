//
//  UserSingleton.swift
//  SnapchatClone
//
//  Created by Cengizhan DUMLU on 11.04.2021.
//

import Foundation

//singleton bir sınıf fakat o sınıf icerisinde tek bir obje olusturuluyor. Hatta sınıftan obje olusturulamıyor.

class UserSingleton{
    
    static let sharedUserInfo = UserSingleton() //user singleton sınıfından olusturulan tek obje olmuş oluyor.
    
    var email = ""
    var username = ""
    
    
    
    private init(){
    //kimse erisemiyor
    }
    
}
