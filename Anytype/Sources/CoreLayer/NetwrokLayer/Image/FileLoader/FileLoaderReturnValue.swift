//
//  FileLoaderReturnValue.swift
//  AnyType
//
//  Created by Kovalev Alexander on 06.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Combine
import Foundation

/// Information about downloading file
final class FileLoaderReturnValue {
    
    /// Download task with possibility to cancel it
    let task: Cancellable
    
    /// Progress publisher to subscribe on progress changes
    let progressPublisher: AnyPublisher<FileLoadingState, Error>
    
    /// initializer
    ///
    /// - Parameters:
    ///   - task: Download task with possibility to cancel it
    ///   - progressPublisher: Progress publisher to subscribe on progress changes
    init(task: Cancellable,
         progressPublisher: AnyPublisher<FileLoadingState, Error>) {
        self.task = task
        self.progressPublisher = progressPublisher
    }
}
