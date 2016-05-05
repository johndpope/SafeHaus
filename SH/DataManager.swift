import Foundation
import Mapbox
import SwiftyJSON
import Alamofire

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
    var searchStrings = [String]()
    
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
            //if(populationAsDouble != 0){
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
                searchStrings.append(searchString)
                let tempBlock = MGLPolygon(coordinates: &boundary, count: UInt(boundaryCount))
                tempBlock.title = String(blockNumberAsInt)
                blockygonCoordinates.append(searchString)
                blockygon.append(tempBlock)
                boundary.removeAll(keepCapacity: false)
            //}
        }
    }
    
    func createCrimeSearchString(coordinates: String) -> String{
        var searchString = "https://data.sfgov.org/resource/cuks-n6tp.json?$where=within_polygon(location, 'MULTIPOLYGON ((("
        searchString = searchString+coordinates
        searchString = searchString + ")))')"
        return searchString
    }
    
    func createMeterSearchString(coordinates: String) -> String{
        var searchString = "https://data.sfgov.org/resource/2iym-9kfb.json?$where=within_polygon(location, 'MULTIPOLYGON ((("
        searchString = searchString+coordinates
        searchString = searchString + ")))')"
        return searchString
    }
    
    func calculateAllCrime(filename: String){
        var cityCrime = 0.0
        let filePath = NSBundle.mainBundle().pathForResource(filename, ofType: "json")
        let jsonData = NSData(contentsOfFile: filePath!)
        let json = JSON(data: jsonData!)
        for i in 0...json.count-1{
            var data = json[i]
            let tempCategory = data["Category"].stringValue
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

class SingletonB {
    
    var meters = [CLLocationCoordinate2D]()
    
    class var sharedInstance : SingletonB {
        struct Static {
            static let instance : SingletonB = SingletonB()
        }
        
        return Static.instance
    }
}
