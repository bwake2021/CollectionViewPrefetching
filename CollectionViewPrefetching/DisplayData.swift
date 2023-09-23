/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that represents the data shown in the collection view.
*/

import UIKit

/// A type to represent how model data should be displayed.
class DisplayData: NSObject {
    
    var color: UIColor = .systemGreen
    
    // Add additional properties for your own configuration here.
    let carouselPageID: CarouselPageId
    let tileIndex: Int
    let startTimeStamp: Date
    let endTimeStamp: Date

    init(_ carousePageID: CarouselPageId, _ startTimeStamp: Date, _ endTimeStamp: Date, _ tileIndex: Int) {

        self.carouselPageID = carousePageID
        self.startTimeStamp = startTimeStamp
        self.endTimeStamp = endTimeStamp
        self.tileIndex = tileIndex
    }
}
