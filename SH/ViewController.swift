//
//  ViewController.swift
//  SH
//
//  Created by Maxwell on 4/10/16.
//  Copyright © 2016 Christopher Brummer. All rights reserved.
//

import Mapbox
import SwiftyJSON
import Alamofire

class ViewController:  UIViewController, MGLMapViewDelegate {
    
    var MapView: MGLMapView!
    var neighborhood = NeighborhoodData(filename: "neighborhood")
    var block = BlockData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        block.getBlock("BlockData")
        //block.calculateAllCrime("crimeCategoryData")
        //intialize map
        MapView = MGLMapView(frame: view.bounds)
        MapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(MapView)
        MapView.delegate = self
        //make touch possible(temp)
        let coordinateFinder = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.revealRegionDetailsWithLongPressOnMap(_:)))
        coordinateFinder.minimumPressDuration = 0.5
        MapView.addGestureRecognizer(coordinateFinder)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Draw the polygons after the map has initialized
    }
    
    //dicates behavior of long press
    func revealRegionDetailsWithLongPressOnMap(gestureRecognizer:UIGestureRecognizer) {
        //use the option key to understand this, pretty self explanatory.
        if gestureRecognizer.state != UIGestureRecognizerState.Began { return }
        //stores the users touch locationch
        let userLocation = gestureRecognizer.locationInView(MapView)
        //converts the touch location to coordinates
        let locationCoordinate = MapView.convertPoint(userLocation, toCoordinateFromView: MapView)
        let mapCirlce = polygonCircleForCoordinate(locationCoordinate, withMeterRadius: 200)
        mapCirlce.title = "userLocation"
        // converts coordinates to MGLCoordinateBounds
        //draw neighborhood and return polygon for reference
        let currentNeighborhood = drawNeighborhoods(mapCirlce.overlayBounds)
        currentNeighborhood?.title = "neighborhood"
        //draw blocks if user is in a neighborhood
        if (currentNeighborhood != nil){
            drawBlocks(mapCirlce, currentNeighborhood: currentNeighborhood!)
        }
        
    }
    
    func drawNeighborhoods(userLocation: MGLCoordinateBounds) -> MGLPolygon? {
        //if theres already been a found user location reintialize annotations in order to clear map
        if(MapView.annotations != nil){
            MapView.removeAnnotations(MapView.annotations!)
        }
        //loop through and find the polygon that intersects the users location
        for i in 0...neighborhood.neighborhoodsCount-1{
            //call file and get neighborhoods by index
            neighborhood.getNeighborhood("neighborhood", index: i)
            // create polygon
            let polygon = MGLPolygon(coordinates: &neighborhood.boundary, count: UInt(neighborhood.boundaryCount))
            //check for intersection
            if(polygon.intersectsOverlayBounds(userLocation)){
                return polygon
            }
        }
        return nil
    }
    
    func drawBlocks(userLocation: MGLPolygon, currentNeighborhood: MGLPolygon){
        //for each block polygon..
        for i in 0...block.blockygon.count-1{
            //check if the block intersects the neighborhood rect..
            if(block.blockygon[i].intersectsOverlayBounds(userLocation.overlayBounds)){
                //add the blocks to the map
                block.blockygon[i].title = "block"
                MapView.addAnnotation(block.blockygon[i])
                queryForMeters(block.createMeterSearchString(block.searchStrings[i]))
                queryForCrime(block.createCrimeSearchString(block.searchStrings[i]))
            }
        }
        //add neighborhood to map
        //MapView.addAnnotation(currentNeighborhood)
    }
    
    func queryForMeters(SearchString: String) {
        SingletonB.sharedInstance.meters.removeAll(keepCapacity: false)
        let query = SearchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        Alamofire.request(.GET, query).responseJSON { (response) in
            var json = JSON(data: response.data!)
            if(json.count != 0){
                for i in 0...json.count-1{
                    var data = json[i]
                    var location = data["location"]
                    var coordinates = location["coordinates"]
                    if (coordinates != "null"){
                        let x = CGFloat(coordinates[1].floatValue)
                        let y = CGFloat(coordinates[0].floatValue)
                        let point = CLLocationCoordinate2DMake(CLLocationDegrees(x), CLLocationDegrees(y))
                        let meter = MGLPointAnnotation()
                        //MGLPolyline(coordinates: &point, count: 1)
                        meter.coordinate = point
                        meter.title = "meter"
                        self.MapView.addAnnotation(meter)
                    }
                }
            }
        }
    }
    
    func queryForCrime(SearchString: String) {
        var cityCrime = 0.0
        let query = SearchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        Alamofire.request(.GET, query).responseJSON { (response) in
            var json = JSON(data: response.data!)
            if(json.count != 0){
                for i in 0...json.count-1{
                    var data = json[i]
                    let tempCategory = data["category"].stringValue
                    if(tempCategory == "ARSON"){
                        cityCrime += 221.93
                    }
                        
                    else if(tempCategory == "ASSAULT"){
                        cityCrime += 5630.52
                    }
                        
                    else if(tempCategory == "BURGLARY"){
                        cityCrime += 273.12
                    }
                        
                    else if(tempCategory == "DISORDERLY CONDUCT"){
                        cityCrime += 43.647
                    }
                        
                    else if(tempCategory == "DRUG/NARCOTIC"){
                        cityCrime += 260.57
                    }
                        
                    else if(tempCategory == "EXTORTION"){
                        cityCrime += 247.97
                    }
                        
                    else if(tempCategory == "FORGERY/COUNTERFEITING"){
                        cityCrime += 234.38
                    }
                        
                    else if(tempCategory == "FRAUD"){
                        cityCrime += 134.11
                    }
                        
                    else if(tempCategory == "GAMBLING"){
                        cityCrime += 5.708
                    }
                        
                    else if(tempCategory == "KIDNAPPING"){
                        cityCrime += 293.17
                    }
                        
                    else if(tempCategory == "LARCENY/THEFT"){
                        cityCrime += 160.54
                    }
                        
                    else if(tempCategory == "LIQUOR LAWS"){
                        cityCrime += 6.493
                    }
                        
                    else if(tempCategory == "PROSTITUTION"){
                        cityCrime += 353.18
                    }
                        
                    else if(tempCategory == "ROBBERY"){
                        cityCrime += 523.33
                    }
                        
                    else if(tempCategory == "SECONDARY CODES"){
                        cityCrime += 43.647
                    }
                        
                    else if(tempCategory == "SEX OFFENSES, FORCIBLE"){
                        cityCrime += 507.15
                    }
                        
                    else if(tempCategory == "SEX OFFENSES, NON FORCIBLE"){
                        cityCrime += 365.7
                    }
                        
                    else if(tempCategory == "STOLEN PROPERTY"){
                        cityCrime += 131.01
                    }
                        
                    else if(tempCategory == "SUSPICIOUS OCC"){
                        cityCrime += 43.647
                    }
                        
                    else if(tempCategory == "TRESPASS"){
                        cityCrime += 29.958
                    }
                        
                    else if(tempCategory == "VANDALISM"){
                        cityCrime += 71.852
                    }
                        
                    else if(tempCategory == "VEHICLE THEFT"){
                        cityCrime += 72.912
                    }
                        
                    else if(tempCategory == "WEAPON LAWS"){
                        cityCrime += 225.79
                    }
                        
                    else{
                        cityCrime += 0
                    }
               }
                print(cityCrime)
            }
        }
    }
    
    func polygonCircleForCoordinate(coordinate: CLLocationCoordinate2D, withMeterRadius: Double) -> MGLPolygon {
        let degreesBetweenPoints = 8.0
        //45 sides
        let numberOfPoints = floor(360.0 / degreesBetweenPoints)
        let distRadians: Double = withMeterRadius / 6371000.0
        // earth radius in meters
        let centerLatRadians: Double = coordinate.latitude * M_PI / 180
        let centerLonRadians: Double = coordinate.longitude * M_PI / 180
        var coordinates = [CLLocationCoordinate2D]()
        //array to hold all the points
        for index in 0 ..< Int(numberOfPoints) {
            let degrees: Double = Double(index) * Double(degreesBetweenPoints)
            let degreeRadians: Double = degrees * M_PI / 180
            let pointLatRadians: Double = asin(sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(degreeRadians))
            let pointLonRadians: Double = centerLonRadians + atan2(sin(degreeRadians) * sin(distRadians) * cos(centerLatRadians), cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians))
            let pointLat: Double = pointLatRadians * 180 / M_PI
            let pointLon: Double = pointLonRadians * 180 / M_PI
            let point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(pointLat, pointLon)
            coordinates.append(point)
        }
        let polygon = MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
       return polygon
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.5
    }
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        
        return UIColor.redColor()
    }
    
    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 5.0
    }
    
    func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        if (annotation.title == "userLocation"){
            return UIColor.grayColor()
        }
        else if(annotation.title == "neighborhood"){
            return UIColor.grayColor()
        }
        else if(annotation.title == "block"){
            return UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1)
        }
        else if(annotation.title == "meter"){
            return UIColor.redColor()
        }
        else{return UIColor.redColor()}

    }
    
    // Use the default marker; see our custom marker example for more information
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        return nil
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    

    
}

