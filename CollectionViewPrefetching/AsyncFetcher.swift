/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that used to mimic fetching data asynchronously.
*/

import Foundation

final class CarouselPageId : NSObject {

    static var pageSize = 8

    let pageIndex: Int
    let carouselId: String

    init(tileIndex: Int, carouselId: String) {
        self.pageIndex = tileIndex / Self.pageSize
        self.carouselId = carouselId
    }

    init(indexPath: IndexPath, carouselId: String) {
        self.pageIndex = indexPath.item / Self.pageSize
        self.carouselId = carouselId
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CarouselPageId else {
            return false
        }
        return pageIndex == other.pageIndex && carouselId == other.carouselId
    }

    override var hash: Int {
        return pageIndex.hashValue ^ carouselId.hashValue
    }

    override var description: String { "ID:\(carouselId) pageIndex:\(pageIndex)" }
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
    private var completionHandlers = [CarouselPageId: [(DisplayData?) -> Void]]()

    /// An `NSCache` used to store fetched objects.
    private var cache = NSCache<CarouselPageId, DisplayData>()

    // MARK: Initialization

    init() {}

    // MARK: Object fetching

    func fetch(_ identifier: String, for indexPath: IndexPath, completion: ((DisplayData?) -> Void)? = nil) {

        let pageIdentifier = CarouselPageId(indexPath: indexPath, carouselId: identifier)
        if let fetchedData = self.fetchedData(for: pageIdentifier, and: indexPath) {

            // The system has fetched and cached the data; use it to configure the cell.
            completion?(fetchedData)

        } else {

            // There is no data available yet; clear the cell until the fetched data arrives.
            completion?(nil)

            // Ask the `asyncFetcher` to fetch data for the specified identifier.
            self.fetchAsync(identifier, indexPath) { fetchedData in
                completion?(fetchedData)
            }
        }
    }

    /**
     Asynchronously fetches data for a specified `UUID`.
     
     - Parameters:
         - identifier: The `UUID` to fetch data for.
         - completion: An optional called when the data has been fetched.
    */
    private func fetchAsync(_ identifier: String, _ indexPath: IndexPath, completion: ((DisplayData?) -> Void)? = nil) {
        // Use the serial queue while we access the fetch queue and completion handlers.
        serialAccessQueue.addOperation {
            // If a completion block has been provided, store it.
            let carouselPageId = CarouselPageId(indexPath: indexPath, carouselId: identifier)
            if let completion = completion {
                let handlers = self.completionHandlers[carouselPageId, default: []]
                self.completionHandlers[carouselPageId] = handlers + [completion]
            }
            
            self.fetchData(for: carouselPageId, indexPath)
        }
    }

    /**
     Returns the previously fetched data for a specified `UUID`.
     
     - Parameter identifier: The `UUID` of the object to return.
     - Parameter indexPath: The particular cell for the UUID
     - Returns: The 'DisplayData' that has previously been fetched or nil.
     */
    private func fetchedData(for identifier: CarouselPageId, and indexPath: IndexPath) -> DisplayData? {
        return cache.object(forKey: identifier)
    }

    /**
     Cancels any enqueued asychronous fetches for a specified `UUID`. Completion
     handlers are not called if a fetch is canceled.
     
     - Parameter identifier: The `UUID` to cancel fetches for.
     */
    func cancelFetch(_ identifier: String, _ item: Int) {
        serialAccessQueue.addOperation {
            let carouselPageId = CarouselPageId(tileIndex: item, carouselId: identifier)

            self.fetchQueue.isSuspended = true
            defer {
                self.fetchQueue.isSuspended = false
            }

            self.operation(for: carouselPageId)?.cancel()
            self.completionHandlers[carouselPageId] = nil
        }
    }

    // MARK: Convenience
    
    /**
     Begins fetching data for the provided `identifier` invoking the associated
     completion handler when complete.
     
     - Parameter identifier: The `UUID` to fetch data for.
     */
    private func fetchData(for identifier: CarouselPageId, _ indexPath: IndexPath) {
        // If a request has already been made for the object, do nothing more.
        if nil != operation(for: identifier) {
            return
        }
        
        if let data = fetchedData(for: identifier, and: indexPath) {
            // The object has already been cached; call the completion handler with that object.
            invokeCompletionHandlers(for: identifier, with: data)
        } else {
            // Enqueue a request for the object.
            let operation = AsyncFetcherOperation(identifier: identifier)
            
            // Set the operation's completion block to cache the fetched object and call the associated completion blocks.
            operation.completionBlock = { [weak operation] in
                guard let fetchedData = operation?.fetchedData else { return }
                self.cache.setObject(fetchedData, forKey: identifier)
                
                self.serialAccessQueue.addOperation {
                    self.invokeCompletionHandlers(for: identifier, with: fetchedData)
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
     Invokes any completion handlers for a specified `CarouselPageId`. Once called,
     the stored array of completion handlers for the `CarouselPageId` is cleared.
     
     - Parameters:
     - identifier: The `CarouselPageId` of the completion handlers to call.
     - object: The fetched object to pass when calling a completion handler.
     */
    private func invokeCompletionHandlers(for identifier: CarouselPageId, with fetchedData: DisplayData) {
        let completionHandlers = self.completionHandlers[identifier, default: []]
        self.completionHandlers[identifier] = nil

        for completionHandler in completionHandlers {
            completionHandler(fetchedData)
        }
    }
}
