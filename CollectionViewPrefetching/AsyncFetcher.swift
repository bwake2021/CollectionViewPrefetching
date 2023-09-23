/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that used to mimic fetching data asynchronously.
*/

import Foundation

/// We fetch data at the page level. Any tile ID, (carousel ID plus tile index)
/// must be turned into a page ID to fetch data. The API currently is _not_
/// paged. We must make paged requests, and deal with possibly getting more
/// than we asked for.
final class CarouselPageId : NSObject {

    static var pageSize = 8

    let carouselId: String
    let pageIndex: Int

    var offset: Int { pageIndex * Self.pageSize }
    var limit: Int { Self.pageSize }
    var end: Int { self.offset + limit }

    var itemIdentifiers: [CarouselTileId] {
        var identifiers = [CarouselTileId]()
        for index in offset ..< end {
            identifiers.append(CarouselTileId(tileIndex: index, carouselId: carouselId))
        }
        return identifiers
    }

    init(tileIndex: Int, carouselId: String) {
        self.pageIndex = tileIndex / Self.pageSize
        self.carouselId = carouselId
    }

    init(indexPath: IndexPath, carouselId: String) {
        self.pageIndex = indexPath.item / Self.pageSize
        self.carouselId = carouselId
    }

    init(itemID: CarouselTileId) {
        self.carouselId = itemID.carouselId
        self.pageIndex = itemID.itemIndex / Self.pageSize
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else {
            return false
        }
        return pageIndex == other.pageIndex && carouselId == other.carouselId
    }

    override var hash: Int {
        return pageIndex.hashValue ^ carouselId.hashValue
    }

    override var description: String { "ID:\(carouselId) pageIndex:\(pageIndex)" }
}

/// We cache data at the item level. Any successful request for carousel tile data
/// will return data for multiple tiles. It may be more than requested. The offset
/// may not be what was requested. We save the returned tile data to the cache
/// at the tile level.

final class CarouselTileId : NSObject {

    let carouselId: String
    let itemIndex: Int

    init(tileIndex: Int, carouselId: String) {
        self.itemIndex = tileIndex
        self.carouselId = carouselId
    }

    init(indexPath: IndexPath, carouselId: String) {
        self.itemIndex = indexPath.item
        self.carouselId = carouselId
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else {
            return false
        }
        return itemIndex == other.itemIndex && carouselId == other.carouselId
    }

    override var hash: Int {
        return itemIndex.hashValue ^ carouselId.hashValue
    }

    override var description: String { "ID:\(carouselId) itemIndex:\(itemIndex)" }
}

/// - Tag: AsyncFetcher
class AsyncFetcher {
    // MARK: Types

    /// A serial `OperationQueue` to lock access to the `fetchQueue` and `completionHandlers` properties.
    private let serialAccessQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    /// An `OperationQueue` that contains `AsyncFetcherOperation`s for requested data.
    private lazy var fetchQueue = OperationQueue()

    /// A dictionary of arrays of closures to call when an object has been fetched for an id.
    private var completionHandlers = [CarouselTileId: [(DisplayData?) -> Void]]()

    /// An `NSCache` used to store fetched objects.
    private var cache = NSCache<CarouselTileId, DisplayData>()

    // MARK: Initialization

    init() {}

    // MARK: Object fetching

    func fetch(_ carouselTileId: CarouselTileId, completion: ((DisplayData?) -> Void)? = nil) {

        if let fetchedData = self.fetchedData(for: carouselTileId) {

            // The system has fetched and cached the data; use it to configure the cell.
            print("data for ID:\(carouselTileId.carouselId) index:\(carouselTileId.itemIndex) found in cache!")
            completion?(fetchedData)

        } else {

            // There is no data available yet; clear the cell until the fetched data arrives.
            completion?(nil)

            // Ask the `asyncFetcher` to fetch data for the specified identifier.
            self.fetchAsync(carouselTileId) { fetchedData in
                completion?(fetchedData)
            }
        }
    }

    /**
     Asynchronously fetches data for a specified `CarouselTileId`.
     
     - Parameters:
         - identifier: The `CarouselTileId` to fetch data for.
         - completion: An optional called when the data has been fetched.
    */
    private func fetchAsync(_ carouselTileId: CarouselTileId, completion: ((DisplayData?) -> Void)? = nil) {
        // Use the serial queue while we access the fetch queue and completion handlers.
        serialAccessQueue.addOperation {
            // If a completion block has been provided, store it.
            if let completion = completion {
                let handlers = self.completionHandlers[carouselTileId, default: []]
                self.completionHandlers[carouselTileId] = handlers + [completion]
            }
            
            self.fetchData(for: carouselTileId)
        }
    }

    /**
     Returns the previously fetched data for a specified `UUID`.
     
     - Parameter identifier: The `UUID` of the object to return.
     - Parameter indexPath: The particular cell for the UUID
     - Returns: The 'DisplayData' that has previously been fetched or nil.
     */
    private func fetchedData(for identifier: CarouselTileId) -> DisplayData? {
        return cache.object(forKey: identifier)
    }

    /**
     Cancels any enqueued asychronous updates for a specified `CarouselItemId`.

     We're paying for the network request, so we might as well cache the data it returns,
     but there's no need to update the UI
     
     - Parameter identifier: The `UUID` to cancel fetches for.
     */
    func cancelFetch(_ identifier: String, _ item: Int) {
        cancelFetch(CarouselTileId(tileIndex: item, carouselId: identifier))
    }

    func cancelFetch(_ carouselTileId: CarouselTileId) {
        serialAccessQueue.addOperation {
            self.completionHandlers[carouselTileId] = nil
        }
    }

    // MARK: Convenience
    
    /**
     Begins fetching data for the provided `CarouselTileId` invoking the associated
     completion handler when complete.
     
     - Parameter carouselTileId: The `CarouselTileId` to fetch data for.
     */
    private func fetchData(for carouselTileId: CarouselTileId) {

        let carouselPageID = CarouselPageId(itemID: carouselTileId)

        // If a request is in flight for the object's page, do nothing more.
        if nil != operation(for: carouselPageID) {
            return
        }
        
        if let data = fetchedData(for: carouselTileId) {
            // The object has already been cached; call the completion handlers with that object.
            invokeCompletionHandlers(for: carouselTileId, with: data)
        } else {
            // Enqueue a request for the object.
            let operation = AsyncFetcherOperation(carouselPageId: carouselPageID)
            
            // Set the operation's completion block to cache the fetched object and call the associated completion blocks.
            operation.completionBlock = { [weak operation] in
                guard let fetchedData = operation?.fetchedData, let carouselPageId = operation?.carouselPageId
                else { return }

                for (index, carouselTileId) in carouselPageId.itemIdentifiers.enumerated() {
                    self.cache.setObject(fetchedData[index], forKey: carouselTileId)

                    self.serialAccessQueue.addOperation {
                        self.invokeCompletionHandlers(for: carouselTileId, with: fetchedData[index])
                    }
                }
            }
            
            fetchQueue.addOperation(operation)
        }
    }

    /**
     Returns any enqueued `ObjectFetcherOperation` for a specified `CarouselPageId`.
     
     - Parameter identifier: The `CarouselPageId` of the operation to return.
     - Returns: The enqueued `ObjectFetcherOperation` or nil.
     */
    private func operation(for carouselPageId: CarouselPageId) -> AsyncFetcherOperation? {
        for case let fetchOperation as AsyncFetcherOperation in fetchQueue.operations
            where !fetchOperation.isCancelled && fetchOperation.carouselPageId == carouselPageId {
            return fetchOperation
        }
        
        return nil
    }

    /**
     Invokes any completion handlers for a specified `CarouselItemId`. Once called,
     the stored array of completion handlers for the `CarouselItemId` is cleared.
     
     - Parameters:
     - identifier: The `CarouselItemId` of the completion handlers to call.
     - object: The fetched object to pass when calling a completion handler.
     */
    private func invokeCompletionHandlers(for identifier: CarouselTileId, with fetchedData: DisplayData) {
        let completionHandlers = self.completionHandlers[identifier, default: []]
        self.completionHandlers[identifier] = nil

        for completionHandler in completionHandlers {
            completionHandler(fetchedData)
        }
    }
}
