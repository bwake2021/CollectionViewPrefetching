//
//  OperationStack.swift
//  CollectionViewPrefetching
//
//  Created by Robert Wakefield on 7/10/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

class OperationStack {
    
    /// A serial `OperationQueue` to lock access to the `queue` and `stack` properties.
    private let serialAccessQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    var operations: [Operation] {
        stack
    }
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private lazy var stack: [Operation] = []
    
    var isSuspended: Bool {
        get {
            queue.isSuspended
        }
        
        set {
            queue.isSuspended = newValue
        }
    }
    
    func addOperation(_ op: Operation) {
        
        serialAccessQueue.addOperation {
            if let operation = op as? AsyncFetcherOperation {
                debugPrint("queue for cell at: \(operation.description)")
            }
            
            let wasSuspended = self.queue.isSuspended
            self.queue.isSuspended = true
            defer {
                self.queue.isSuspended = wasSuspended
            }
            
            self.stack.append(op)

            if self.queue.operations.isEmpty {
                self.serialAccessQueue.addBarrierBlock(self.addStackedOperation)
            }
        }
    }
    
    func addOperation(_ block: @escaping () -> Void) {
        self.addOperation(BlockOperation(block: block))
    }
    
    private func addStackedOperation() {
        
        serialAccessQueue.addOperation {
            let wasSuspended = self.queue.isSuspended
            self.queue.isSuspended = true
            defer {
                self.queue.isSuspended = wasSuspended
            }

            if !self.stack.isEmpty {
                let nextOperation = self.stack.removeLast()
                if let operation = nextOperation as? AsyncFetcherOperation {
                    debugPrint("fetch for cell at: \(operation.description)")
                }
                self.queue.addOperation(nextOperation)
                if !self.stack.isEmpty {
                    self.queue.addBarrierBlock(self.addStackedOperation)
                }
            }
         }
    }
    
    func rescheduleOperation(_ op: Operation) {
        
        serialAccessQueue.addOperation {
            let wasSuspended = self.queue.isSuspended
            self.queue.isSuspended = true
            defer {
                self.queue.isSuspended = wasSuspended
            }

            if let index = self.stack.firstIndex(of: op) {
                if let operation = op as? AsyncFetcherOperation {
                    debugPrint("reschedule for cell at: \(operation.description)")
                }
                self.stack.remove(at: index)
                self.stack.append(op)
            }
        }
    }
}
