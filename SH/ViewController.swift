//
//  ViewController.swift
//  SH
//
//  Created by Maxwell on 4/10/16.
//  Copyright © 2016 Christopher Brummer. All rights reserved.
//

import Mapbox


class ViewController:  UIViewController, MGLMapViewDelegate {
    
    var MapView: MGLMapView!
    var neighborhood = NeighborhoodData(filename: "neighborhood")
    var block = BlockData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        block.getBlock("BlockData")
        //intialize map
        MapView = MGLMapView(frame: view.bounds)
        MapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(MapView)
        MapView.delegate = self
        //make touch possible(temp)
        let coordinateFinder = UILongPressGestureRecognizer(target: self, action: "revealRegionDetailsWithLongPressOnMap:")
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
        let mapCirlce = polygonCircleForCoordinate(locationCoordinate, withMeterRadius: 400)
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
            }
        }
        //add neighborhood to map
        //MapView.addAnnotation(currentNeighborhood)
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
        for var index = 0; index < Int(numberOfPoints); index++ {
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
        
        return UIColor.whiteColor()
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
        else{return UIColor.whiteColor()}

    }
    

    
}

