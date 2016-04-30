import Foundation
import Mapbox
import SwiftyJSON

class NeighborhoodData {
    var boundary: [CLLocationCoordinate2D]
    var neighborhoodsCount: NSInteger
    var boundaryCount: NSInteger
    var adjacentNeighborhoods: String
    var name: String
    var primary: Bool
    
    init(filename: String) {
        let filePath = NSBundle.mainBundle().pathForResource(filename, ofType: "plist")
        let properties = NSDictionary(contentsOfFile: filePath!)
        name = "" as String
        let neighborhoods = properties!["features"] as! NSArray
        neighborhoodsCount = neighborhoods.count
        boundaryCount = 0
        boundary = []
        adjacentNeighborhoods = "" as String
        primary = false
    }
    
    func getNeighborhood(filename: String, index: Int){
        boundary.removeAll(keepCapacity: false)
        let filePath = NSBundle.mainBundle().pathForResource(filename, ofType: "plist")
        let properties = NSDictionary(contentsOfFile: filePath!)
        
        let neighborhoods = properties!["features"] as! NSArray
        let neighborhoodGeometry = neighborhoods[index].objectForKey("geometry")
        let neighborHoodProperties = neighborhoods[index].objectForKey("properties")
        let neighborhoodCoordinates = neighborhoodGeometry!.objectForKey("coordinates") as! NSArray
        let neighborhoodBoundary = neighborhoodCoordinates[0] as! NSArray
        boundaryCount = neighborhoodBoundary.count
        
        for i in 0...boundaryCount-1 {
            self.name = neighborHoodProperties!.objectForKey("title") as! String
            self.adjacentNeighborhoods = neighborHoodProperties!.objectForKey("description")! as! String
            let neighborhoodBoundaryCoordinates = neighborhoodBoundary[i] as! NSArray
            let stringConversion = ("{"+neighborhoodBoundaryCoordinates[0].stringValue+","+neighborhoodBoundaryCoordinates[1].stringValue+"}")
            let p = CGPointFromString(stringConversion)
            boundary += [CLLocationCoordinate2DMake(CLLocationDegrees(p.y), CLLocationDegrees(p.x))]
        }
        
    }
    
}


class BlockData {
    
    var boundary = [CLLocationCoordinate2D]()
    var boundaryCount = Int()
    var population = [Double]()
    var blockNumber = [Int]()
    var blockCount = Int()
    var blockygonCoordinates = [String]()
    var blockygon = [MGLPolygon]()
    
    func getBlock(filename: String){
        boundary.removeAll(keepCapacity: false)
        let filePath = NSBundle.mainBundle().pathForResource(filename, ofType: "json")
        let jsonData = NSData(contentsOfFile: filePath!)
        let json = JSON(data: jsonData!)
        let features = json["features"].arrayObject!
        blockCount = features.count
        
        
        for i in 0...blockCount-1 {
            let geometry = features[i].objectForKey("geometry")
            let properties = features[i].objectForKey("properties")
            let coordinates = geometry!.objectForKey("coordinates") as! NSArray
            let boundaries = coordinates[0] as! NSArray
            boundaryCount = boundaries.count
            let populationAsDouble = (properties!.objectForKey("POP_BLOC11") as! NSString).doubleValue
            let blockNumberAsInt = (properties!.objectForKey("BLOCKCE10") as! NSString).integerValue
            var searchString:String = ""
            if(populationAsDouble != 0){
                self.population.append(populationAsDouble)
                self.blockNumber.append(blockNumberAsInt)
                
                for k in 0...boundaryCount-1 {
                    let boundaryCoordinates = boundaries[k] as! NSArray
                    searchString = searchString+(boundaryCoordinates[0].stringValue+" "+boundaryCoordinates[1].stringValue+",")
                    let stringConversion = ("{"+boundaryCoordinates[0].stringValue+","+boundaryCoordinates[1].stringValue+"}")
                    let p = CGPointFromString(stringConversion)
                    boundary += [CLLocationCoordinate2DMake(CLLocationDegrees(p.y), CLLocationDegrees(p.x))]
                }
                searchString = String(searchString.characters.dropLast())
                let tempBlock = MGLPolygon(coordinates: &boundary, count: UInt(boundaryCount))
                tempBlock.title = String(blockNumberAsInt)
                blockygonCoordinates.append(searchString)
                blockygon.append(tempBlock)
                boundary.removeAll(keepCapacity: false)
            }
        }
    }
}
