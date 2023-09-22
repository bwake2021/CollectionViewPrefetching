/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An `Operation` subclass used by `AsyncFetcher` to mimic slow network requests for data.
*/

import Foundation

class AsyncFetcherOperation: Operation {
    // MARK: Properties

    /// The `UUID` that the operation is fetching data for.
    let carouselPageId: CarouselPageId
    let startTimeStamp = Date()

    /// The `DisplayData` that has been fetched by this operation.
    private(set) var fetchedData: DisplayData?

    // MARK: Initialization

    init(identifier: CarouselPageId) {
        self.carouselPageId = identifier

        super.init()
    }

    // MARK: Operation overrides

    override func main() {
        // Wait for a second to mimic a slow operation.
        Thread.sleep(until: Date().addingTimeInterval(1))
        guard !isCancelled else { return }
        
        fetchedData = DisplayData(self.carouselPageId, self.startTimeStamp, Date())
        
        debugPrint("data for \(carouselPageId) fetched!")
    }

    override var description: String { "fetch: \(carouselPageId.description)" }
}
