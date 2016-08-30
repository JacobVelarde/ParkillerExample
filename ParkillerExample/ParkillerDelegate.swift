//
//  ParkillerDelegate.swift
//  ParkillerExample
//
//  Created by Jacob Velarde on 18/08/16.
//  Copyright © 2016 Jacob Velarde. All rights reserved.
//

import UIKit
import Social

protocol parKillerDelegate {
    func seleccionAlert(response:String, typeAlert:Int)
}

class ParkillerDelegate {
    
    var delegate: parKillerDelegate?
    
    func showDestinationAlert(view:UIViewController){
        
        let alertController = UIAlertController(title: "Alerta", message: "Selecciona un destino para continuar", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            //HAGO ALGO?
        })
        
        alertController.addAction(ok)
        
        view.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showGenericAlert(view:UIViewController, tittle:String, message:String, typeAlert:Int){
        
        let alertController = UIAlertController(title: tittle, message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            
            print("ok")
            self.delegate?.seleccionAlert("OK",typeAlert: typeAlert)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            
            print("cancel")
            self.delegate?.seleccionAlert("CANCEL",typeAlert: typeAlert)
        })
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        
        view.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func distanceBetweenTwoPoint(latOne:Double, lonOne:Double, latTwo:Double, lonTwo:Double)->NSMutableArray{
        
        let R : Double = 6371;
        let lat = deg2rad(latTwo-latOne)
        let lon = deg2rad(lonTwo-lonOne)
        
        let a = sin(lat/2) * sin(lat/2) + cos(deg2rad(latOne)) * cos(deg2rad(latTwo)) * sin(lon/2) * sin(lon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        var d = R * c
        
        print("Distance: ", d)
        
        d = roundKm(d)
        
        let distances : NSMutableArray = [String(format:"%f", d), String(format:"%f",roundKm(kmToMeters(d)))]
        
        return distances

    }
    
    func deg2rad(deg:Double) -> Double {
        return deg * (M_PI/180)
    }
    func kmToMeters(km:Double)->Double{
        return km * 1000
    }
    
    func getMessageFromDistance(distance:Double)->String{

        if distance>200 {
            return "Estás muy lejos del punto objetivo"
        }else if distance>100 && distance<=200{
            return "Estás lejos del punto objetivo"
        }else if distance>50 && distance<=100{
            return "Estás próximo al punto objetivo"
        }else if distance>10 && distance<=50{
            return "Estás muy próximo al punto objetivo"
        }else if distance<=10{
            return "Estás en el punto objetivo"
        }
        
        return "No disponible"
    }
    
    func getAddressForLatLng(latitude: String, longitude: String) ->String {
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=AIzaSyBTDbGRHRETcDkyXCD2-kA86xIvONdrles")
        let data = NSData(contentsOfURL: url!)
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        if let result = json["results"] as? NSArray {
            if let address = result[0]["address_components"] as? NSArray {
                let number = address[0]["short_name"] as! String
                let street = address[1]["short_name"] as! String
                print("\n\(number) \(street)")
                
                return  number+" "+street
            }
        }
        
        return ""
    }
    
    func roundKm(km:Double)->Double{
      return  round(1000 * km) / 1000
    }
    
    func setNotification(message : String){
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        notification.applicationIconBadgeNumber = 1
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func searchPlaces(place: String, client: SearchResultsController){
        
//        _ = place.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.symbolCharacterSet())
        let cad = place.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(cad)&types=geocode&key=AIzaSyBTDbGRHRETcDkyXCD2-kA86xIvONdrles")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            do {
                if data != nil{
                    let dic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves) as! NSDictionary
                    let lat = dic["predictions"]?.valueForKey("description")
                    print(lat)
                    client.reloadDataWithArray(lat as! NSArray as! [String])
                }
                
            }catch {
                print("Error")
            }
        }
        task.resume()
    }
    
    func getScreenShot()->UIImage {
        let layer = UIApplication.sharedApplication().keyWindow!.layer
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    
    func sharedTwitter(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetSheet.setInitialText("Estoy aquí!")
            tweetSheet.addImage(getScreenShot())
            UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(tweetSheet, animated: true, completion: nil)
        } else {
            print("No se pudo publicar en Twitter")
            showGenericAlert((UIApplication.sharedApplication().keyWindow?.rootViewController)!, tittle: "Aviso", message: "Vincule la cuenta de Twitter a su iPhone desde configuraciones y reinicie su destino :)", typeAlert: 4)
        }
    }
}









