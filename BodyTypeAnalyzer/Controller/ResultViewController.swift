//
//  ViewController.swift
//  BodyTypeAnalyzer
//
//  Created by Pema Sherpa on 4/1/22.
//

import UIKit

var imageHeight = 0
var imageWidth = 0

class ViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bodyDiagram: UIImageView!
    @IBOutlet weak var resultsTitle: UILabel!
    @IBOutlet weak var resultInfo: UILabel!
    
    /*I am trying to send a image to the bodypose handler*/
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Start of View Controller")
        
        let bodyType = BodyTypeBrain(userImage: UIImage(named:"black")!)
        
        bodyType.startAnalyzingImage()

        print("After Brain Called")
        
        bodyDiagram.image = retrieveImage(forKey: "Body Diagram")
        resultInfo.text = "Haha this is filler text, nice weather we're having right? x + y = xy? 1 + 2 = 12?"
        resultsTitle.text = bodyType.calculateBodyType()
        
        print("end of View Controller")

    }

    private func retrieveImage(forKey key: String) -> UIImage? {
        print("Start of Retrieve image")
        
               if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
                   let image = UIImage(data: imageData) {
                   return image
               }
                return nil
           }
           
}
