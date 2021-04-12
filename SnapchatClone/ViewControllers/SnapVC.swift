//
//  SnapVC.swift
//  SnapchatClone
//
//  Created by Cengizhan DUMLU on 11.04.2021.
//

import UIKit
import ImageSlideshow

class SnapVC: UIViewController {
    
    
    @IBOutlet weak var timeLabel: UILabel!
    
    var selectedSnap : Snap?
    var inputArray = [KingfisherSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if let snap = selectedSnap {
            
            timeLabel.text = "Time Left: \(snap.timeDifference )"
            
            for imageUrl in snap.imageUrlArray { //boyle image urllerine ulasabiliriz
                inputArray.append(KingfisherSource(urlString: imageUrl)!)
            }
            
            
            //gorunum olusturmanın aynısı olacak
            let imageSlideShow = ImageSlideshow(frame: CGRect(x: 10, y: 10, width: self.view.frame.width * 0.95, height: self.view.frame.height * 0.90))
            imageSlideShow.backgroundColor = UIColor.white
            
            let pageIndicator = UIPageControl()
            pageIndicator.currentPageIndicatorTintColor = UIColor.lightGray
            pageIndicator.pageIndicatorTintColor = UIColor.black
            imageSlideShow.pageIndicator = pageIndicator
            
            imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFit
            imageSlideShow.setImageInputs(inputArray)
            self.view.addSubview(imageSlideShow)
        }
    }
    

}
