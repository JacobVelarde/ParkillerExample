//
//  ViewController.swift
//  ParkillerExample
//
//  Created by Jacob Velarde on 17/08/16.
//  Copyright © 2016 Jacob Velarde. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, CLLocationManagerDelegate, parKillerDelegate, LocateOnTheMap, UISearchBarDelegate {

    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var buttonGo: UIButton!
    @IBOutlet weak var lblDistanceKm: UILabel!
    @IBOutlet weak var lblDistanceMeters: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    
    var searchResultController:SearchResultsController!
    var resultsArray = [String]()

    var locationManager = CLLocationManager()
    let doubleTapGesture = UITapGestureRecognizer()
    let tapGesture = UITapGestureRecognizer()
    let parKillerDelegate = ParkillerDelegate()
    var firstViewInformation = Bool()
    var isMarker = Bool()
    var isSharedTwitter = Bool()
    var isNotificationSend = Bool()
    var marker = GMSMarker()
    var updateLocationStart = Bool()
    var latitudeDestination = Double()
    var longitudeDestination = Double()
    var isRunDistance = Bool()
    
    var twoHundredMeters = Bool()
    var oneHundredMeters = Bool()
    var fiftyMeters = Bool()
    var tenMeters = Bool()
    var nineMeters = Bool()
 

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customGoogleMaps()
        addGesture()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        parKillerDelegate.delegate = self
        configureRules()
        customLabel()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setSearchBar()
        showInformationView()
    }
    
    func setSearchBar(){
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
    }
    
    func configureRules(){
        firstViewInformation = false
        updateLocationStart = false
        isRunDistance = false
        isSharedTwitter = false
        twoHundredMeters = false
        oneHundredMeters = false
        fiftyMeters = false
        tenMeters = false
        nineMeters = false
    }
    
    func resetNotification(){
        twoHundredMeters = false
        oneHundredMeters = false
        fiftyMeters = false
        tenMeters = false
        nineMeters = false
    }
    
    func customGoogleMaps(){
        self.googleMaps.settings.consumesGesturesInView = false
        isMarker = false
    }
    
    func removeGesture(){
        self.googleMaps.removeGestureRecognizer(doubleTapGesture)
        self.googleMaps.removeGestureRecognizer(tapGesture)
    }
    
    func addGesture(){
        self.doubleTapGesture.numberOfTapsRequired = 2
        self.tapGesture.numberOfTapsRequired = 3
        self.doubleTapGesture.addTarget(self, action: #selector(ViewController.addMark(_:)))
        self.tapGesture.addTarget(self, action: #selector(ViewController.removeMark(_:)))
        self.googleMaps.addGestureRecognizer(self.doubleTapGesture)
        self.googleMaps.addGestureRecognizer(self.tapGesture)

    }
    
    func addMarkWithGesture(gestureReconizer: UITapGestureRecognizer, tap: Bool){
        let longPressPoint = gestureReconizer.locationInView(self.googleMaps)
        let coordinate = googleMaps.projection.coordinateForPoint(longPressPoint)
        marker = GMSMarker(position: coordinate)
        marker.opacity = 0.6
        marker.map = googleMaps
        marker.icon = UIImage(named: "marker")
        isMarker = true
        latitudeDestination = coordinate.latitude
        longitudeDestination = coordinate.longitude
        marker.title = parKillerDelegate.getAddressForLatLng(String(format:"%f", latitudeDestination), longitude: String(format:"%f",longitudeDestination))
        addCirlce(coordinate, r: 200, color: UIColor.redColor())
        addCirlce(coordinate, r: 100, color: UIColor.yellowColor())
        addCirlce(coordinate, r: 50, color: UIColor.blueColor())
        addCirlce(coordinate, r: 10, color: UIColor.greenColor())
    }
    
    func addMarkWithLatLong(coordinate: CLLocationCoordinate2D){
        marker = GMSMarker(position: coordinate)
        marker.opacity = 0.6
        marker.map = googleMaps
        marker.icon = UIImage(named: "marker")
        isMarker = true
        latitudeDestination = coordinate.latitude
        longitudeDestination = coordinate.longitude
        marker.title = parKillerDelegate.getAddressForLatLng(String(format:"%f", latitudeDestination), longitude: String(format:"%f",longitudeDestination))
        addCirlce(coordinate, r: 200, color: UIColor.redColor())
        addCirlce(coordinate, r: 100, color: UIColor.yellowColor())
        addCirlce(coordinate, r: 50, color: UIColor.blueColor())
        addCirlce(coordinate, r: 10, color: UIColor.greenColor())
    }
    
    func addMark(gestureReconizer: UITapGestureRecognizer){
        
        if !isMarker {
            addMarkWithGesture(gestureReconizer, tap: true)
        }
    }
    
    func removeMark(gestureReconizer: UITapGestureRecognizer){
        if isMarker{
            parKillerDelegate.showGenericAlert(self, tittle: "Aviso", message: "¿Desea modificar el destino ó limpiar el mapa?", typeAlert: 0)
        }
    }
    
    func showInformationView(){
        if !firstViewInformation {
            firstViewInformation = true
            let popoverInformation = self.storyboard?.instantiateViewControllerWithIdentifier("readMeID") as! ReadMeViewController
            popoverInformation.modalPresentationStyle = .Popover
            self.presentViewController(popoverInformation, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonGo(sender: AnyObject) {
        
        if (TARGET_OS_SIMULATOR == 0){
        
            if !isRunDistance{
                if isMarker {
                    parKillerDelegate.showGenericAlert(self, tittle: "Alerta", message: "¿Desea iniciar el destino?", typeAlert: 1)
                }else{
                    parKillerDelegate.showDestinationAlert(self)
                }
            }else{
                parKillerDelegate.showGenericAlert(self, tittle: "Alerta", message: "¿Desea cancelar el recorrido?", typeAlert: 2)
            }
            
        }else{
            parKillerDelegate.showGenericAlert(self, tittle: "AVISO", message: "Ejecutar la aplicación en dispositivo fisico", typeAlert: 5)
        }
    }
    
    @IBAction func SearchPlace(sender: AnyObject) {
        
        if isRunDistance {
            parKillerDelegate.showGenericAlert(self, tittle: "Alerta", message: "¿Desea cancelar el recorrido?", typeAlert: 2)
        }else{
            let searchController = UISearchController(searchResultsController: searchResultController)
            searchController.searchBar.delegate = self
            self.presentViewController(searchController, animated: true, completion: nil)
        }
    }
    
    func validateNotification(distance : Double, message : String){
        
        if distance <= 10 && !nineMeters {
            parKillerDelegate.setNotification(message)
            nineMeters = true
            tenMeters = false
            fiftyMeters = false
            oneHundredMeters = false
            twoHundredMeters = false
            
        }else if distance > 10 && distance <= 50 && !tenMeters{
            parKillerDelegate.setNotification(message)
            nineMeters = false
            tenMeters = true
            fiftyMeters = false
            oneHundredMeters = false
            twoHundredMeters = false
            return
        }else if distance > 50 && distance <= 100 && !fiftyMeters{
            parKillerDelegate.setNotification(message)
            nineMeters = false
            tenMeters = false
            fiftyMeters = true
            oneHundredMeters = false
            twoHundredMeters = false
            return
        }else if distance > 100 && distance <= 200 && !oneHundredMeters{
            parKillerDelegate.setNotification(message)
            nineMeters = false
            tenMeters = false
            fiftyMeters = false
            oneHundredMeters = true
            twoHundredMeters = false
            return
        }else if distance > 200 && !twoHundredMeters{
            parKillerDelegate.setNotification(message)
            nineMeters = false
            tenMeters = false
            fiftyMeters = false
            oneHundredMeters = false
            twoHundredMeters = true
            return
        }
        
    }
    
    func customButonStop(){
        buttonGo.setTitle("STOP", forState: UIControlState.Normal)
        buttonGo.titleLabel?.textAlignment = .Center
        buttonGo.tintColor = UIColor.blackColor()
        
    }
    
    func  customButonStart() {
        buttonGo.setTitle("", forState: UIControlState.Normal)

    }
    
    func customLabel(){
        lblDistanceKm.text = "Bienvenido!"
        lblDistanceMeters.text = "Tap para empezar ->"
        lblMessage.text = ""
    }
    
    func addCirlce(position: CLLocationCoordinate2D, r: Double, color : UIColor){
        let circ = GMSCircle(position: position, radius: r)
        circ.strokeColor = color
        circ.strokeWidth = 5
        circ.map = googleMaps;
    }
    

    //Protocols Location
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            googleMaps.settings.myLocationButton = true
            googleMaps.myLocationEnabled = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first{
            
            if !updateLocationStart{
                googleMaps.camera = GMSCameraPosition(target: location.coordinate,zoom: 17, bearing: 0, viewingAngle: 0)
                locationManager.stopUpdatingLocation()
                
            }else{
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.googleMaps.camera = GMSCameraPosition(target: location.coordinate,zoom: 17, bearing: 30, viewingAngle: 0)
                }
                let distances = parKillerDelegate.distanceBetweenTwoPoint((manager.location?.coordinate.latitude)!, lonOne: (manager.location?.coordinate.longitude)!, latTwo: latitudeDestination, lonTwo: longitudeDestination)
                
                let distanceKm = distances[0] as? String
                let distanceM = distances[1] as? String
                
                lblDistanceKm.text = distanceKm! + " Km"
                lblDistanceMeters.text = distanceM! + " M"
                lblMessage.text = parKillerDelegate.getMessageFromDistance(Double (distanceM!)!)
                
                if  Double(distanceM!)!<=10 && !isSharedTwitter {
                    parKillerDelegate.sharedTwitter()
                    isSharedTwitter = true
                }
                
                validateNotification(Double(distanceM!)!, message: lblMessage.text!)
            }
        }
    }
    
    //Protocols parKiller
    func seleccionAlert(response: String, typeAlert: Int) {
        
        switch typeAlert {
        case 0:
            //Modificar destino
            if response == "OK" {
                
                marker.map = nil
                googleMaps.clear()
                isMarker = false
                resetNotification()
            }else if response == "CANCEL"{
                
                isMarker = true
            }
            
            break;
            //Iniciar destino
        case 1:
            
            if response == "OK" {
                
                customButonStop()
                removeGesture()
                updateLocationStart = true
                isRunDistance = true
                locationManager.startUpdatingLocation()
                isSharedTwitter = false
            }else if response == "CANCEL"{
                
                customLabel()
                customButonStart()
                addGesture()
                updateLocationStart = false
                locationManager.stopUpdatingHeading()
                resetNotification()

            }
            
            break;
            
        case 2:
            //Cancelar el recorrido
            if response == "OK" {
                customLabel()
                customButonStart()
                addGesture()
                updateLocationStart = false
                isRunDistance = false
                locationManager.stopUpdatingHeading()
                resetNotification()
            }else if response == "CANCEL"{
                //Hacer algo?
            }
            break;
            
        default:
            break;
            
        }
    }
    
    func locateWithLongitude(lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let position = CLLocationCoordinate2DMake(lat, lon)
            self.googleMaps.clear()
            self.googleMaps.camera = GMSCameraPosition.cameraWithLatitude(lat, longitude: lon, zoom: 17)
            self.addMarkWithLatLong(position)
            
            
        }
    }
    
    func searchBar(searchBar: UISearchBar,
                   textDidChange searchText: String){
        
        parKillerDelegate.searchPlaces(searchText, client: searchResultController)
        
    }
    
    
 
}

