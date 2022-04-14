//
//  BodyTypeBrain.swift
//  BodyTypeAnalyzer
//
//  Created by Pema Sherpa on 4/6/22.
//

import UIKit
import  CoreML
import Vision

class BodyTypeBrain{
    
    var userImage: UIImage
    
    init(userImage: UIImage) {
        self.userImage = userImage
        }

    /*Code Provided by Documentation to Retrieve Points from Body Pose Model*/
    func startAnalyzingImage(){
        
        // Get the CGImage on which to perform requests.
        guard let cgImage = userImage.cgImage else { return }
        
        imageHeight = cgImage.height
        imageWidth = cgImage.width
        
        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        // Create a new request to recognize a human body pose.
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)
        
        do {
            // Perform the body pose-detection request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request: \(error).")
        }

    }//end of startAnalyzingImage
    
    /* returns a unique observation for each detected human body pose, with each containing
     the recognized points and a confidence score indicating the accuracy of the observation.*/
    func bodyPoseHandler(request: VNRequest, error: Error?) {
        print("Start of bodyPoseHandler")
        
        guard let observations =
                request.results as? [VNHumanBodyPoseObservation] else {
            return
        }
    
        // Process each observation to find the recognized body pose points.
        observations.forEach { processObservation($0) }
        

    }
    
    /*Retrieves all points in body*/
    func processObservation(_ observation: VNHumanBodyPoseObservation) {
        print("Start of processObservation")

        guard let recognizedPoints =
                try? observation.recognizedPoints(.all) else { return }
        
        //why does it have to be flipped? something to do with the image Uiimage vs Ciimage?
        let jointNames: [VNHumanBodyPoseObservation.JointName] = [
            .rightShoulder,
             .leftShoulder,
            .rightElbow,
            .leftElbow,
             .rightHip,
             .leftHip,
             
        ]
        
        
        // Retrieve the CGPoints containing the normalized X and Y coordinates.
     
        var imagePoints: [CGPoint] = jointNames.compactMap {
            
            guard let point = recognizedPoints[$0], point.confidence > 0 else { return nil }
            
            // Translate the point from normalized-coordinates to image coordinates.
            return VNImagePointForNormalizedPoint(point.location,
                                                  Int((userImage.size.width)),
                                                  Int((userImage.size.height))
                                                                                  )
        }

      
        for i in 0...imagePoints.count - 1{
            imagePoints[i].y = userImage.size.height - imagePoints[i].y                                     //adjusting height b/c cimage -> uiimage
            imagePoints[i].x = updatePoint(oldPoint: imagePoints[i], index:i)
        }
   
        store(image: drawLineOnImage(userImagePoints: imagePoints), forKey: "Body Diagram")


} // end of processObservation

    
    func updatePoint( oldPoint: CGPoint, index: Int) -> CGFloat{
        Swift.print("Start of updatePoint")

        var x = Int((oldPoint.x))
        let y = Int((oldPoint.y))

        let color = userImage.pixelColor( x: x, y:  y)
      
        Swift.print("Old color: \(color) old point: \(oldPoint)")
        
        var currentColor = color
        
        if(index  == 1 || index  == 5 || index == 2 ){

               x += 1
            
               while(inSameColorRange(oldColor: color, newColor: currentColor) && x >= 0){

                   currentColor = userImage.pixelColor( x: x, y:  y)
                
                   x += 1
            }

        }
       else {
           
            x -= 1
            while(inSameColorRange(oldColor: color, newColor: currentColor ) && x < userImage.pixelWidth){
                currentColor = userImage.pixelColor( x: x, y:  y)
                x -= 1
            }

        }
        return CGFloat(x)
  }
    
    func calculateBodyType() -> String{
        
        return "Rectangle"
    }
    
    
    
    
    
    func inSameColorRange(oldColor: UIColor, newColor: UIColor) -> Bool{
        let percent: Float = 0.3
        let r = abs(Float(oldColor.rgba.red - newColor.rgba.red))
        let g = abs(Float(oldColor.rgba.green - newColor.rgba.green))
        let b = abs(Float(oldColor.rgba.blue - newColor.rgba.blue))
        
        if(r < percent && g < percent && b < percent){
            return true
        }
        return false
    }
    
    
    /*Edits user image by adding lines of proposed bodytype to prove the accuracy of the calculation*/
    func drawLineOnImage(userImagePoints imagePoints: [CGPoint]) -> UIImage{
        
        UIGraphicsBeginImageContext(userImage.size)
        userImage.draw(at:CGPoint.zero)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        context.setLineWidth(3.0)                            //depends on size of image, remember!!!  (ex. 3.0 for 414 x 414)
        context.setStrokeColor(UIColor.systemYellow.cgColor)
       
        var i = 0
        //Draws line from joint to joint
        while(i < imagePoints.count - 1){
    
            context.move(to: imagePoints[i])
            i += 1
            context.addLine(to: imagePoints[i])
            context.strokePath()
            i += 1
        }
        
        i = 0
        //Draw lines connecting the previously created lines
        while(i < 4){
            context.move(to: imagePoints[i])
            context.addLine(to: imagePoints[i + 2])
            context.strokePath()
            i += 1
        }

        guard let resultImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return resultImage

    }
/*Stores edited user image to retrieve at ResultsViewController*/
    private func store(image: UIImage,forKey key: String) {

           if let pngRepresentation = image.pngData() {
                   UserDefaults.standard.set(pngRepresentation,
                                             forKey: key)
               }

           }
       
}
