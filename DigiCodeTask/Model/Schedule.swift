//
//
//  Created by Alexey Chebotarev on 3/15/16.
//  Copyright © 2016 Alexey Chebotarev. All rights reserved.
//

import Foundation
import UIKit

@objc class Schedule: NSObject, NSCoding {
    var id : NSNumber
    var providerLogo: NSURL
    var priceInEuros: Float
    var departureTime: NSDate
    var arrivalTime: NSDate
    var numberOfstops: Int
    var imageLogo: UIImage?
    var timeInterval: TimeInterval

    init(id: NSNumber, providerLogo: NSURL, priceInEuros: Float, departureTime: NSDate,  arrivalTime: NSDate, numberOfstops:Int, imageLogo:UIImage?) {
        self.id = id
        self.providerLogo = providerLogo
        self.priceInEuros = priceInEuros
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.numberOfstops = numberOfstops
        self.imageLogo = imageLogo
        self.timeInterval = arrivalTime.timeIntervalSince(departureTime as Date)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.id  = (aDecoder.decodeObject(forKey: "id") as? NSNumber)!
        self.providerLogo = (aDecoder.decodeObject(forKey: "providerLogo") as? NSURL)!
        self.priceInEuros = aDecoder.decodeFloat(forKey: "priceInEuros")
        self.departureTime = aDecoder.decodeObject(forKey: "departureTime") as! NSDate
        self.arrivalTime = aDecoder.decodeObject(forKey: "arrivalTime") as! NSDate
        self.numberOfstops = Int(aDecoder.decodeInt32(forKey: "numberOfstops"))
        self.imageLogo = aDecoder.decodeObject(forKey: "imageLogo") as? UIImage
        self.timeInterval = aDecoder.decodeDouble(forKey: "timeInterval")
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(providerLogo, forKey: "providerLogo")
        aCoder.encode(priceInEuros, forKey: "priceInEuros")
        aCoder.encode(departureTime, forKey: "departureTime")
        aCoder.encode(arrivalTime, forKey: "arrivalTime")
        aCoder.encode(numberOfstops, forKey: "numberOfstops")
        aCoder.encode(imageLogo, forKey: "imageLogo")
        aCoder.encode(timeInterval, forKey: "timeInterval")
    }
}
