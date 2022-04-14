//
//  HomePageViewController.swift
//  BodyTypeAnalyzer
//
//  Created by Pema Sherpa on 4/6/22.
//

import UIKit

/*
 This is the placeholder for a potential homepage
 */
class HomePageViewController: ViewController{
    
    //Need to implement a way for users to upload image
    //probably add button
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        _ = BodyTypeBrain(userImage: UIImage(named:"standing_girl")!)

}
    //upload image on this page
}
