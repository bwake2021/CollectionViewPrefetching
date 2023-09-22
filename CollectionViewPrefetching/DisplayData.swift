/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that represents the data shown in the collection view.
*/

import UIKit

/// A type to represent how model data should be displayed.
class DisplayData: NSObject {
    
    private static var serialAccessQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    var color: UIColor = .systemGreen
    
    // Add additional properties for your own configuration here.
    let carouselPageID: CarouselPageId
    let startTimeStamp: Date
    let endTimeStamp: Date

    var isPlaceholder: Bool { endTimeStamp < startTimeStamp }
    
    init(_ carousePageID: CarouselPageId, _ startTimeStamp: Date, _ endTimeStamp: Date) {

        self.carouselPageID = carousePageID
        self.startTimeStamp = startTimeStamp
        self.endTimeStamp = endTimeStamp
    }

    static let placeholder = DisplayData(CarouselPageId(tileIndex: -1, carouselId: ""), .distantFuture, .distantPast)
}
