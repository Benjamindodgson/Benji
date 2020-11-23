//
//  TCHMessageOptions.swift
//  Benji
//
//  Created by Benji Dodgson on 8/22/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import TMROFutures

extension TCHMessageOptions {

    func with(body: String, attributes: TCHJsonAttributes) -> Future<TCHMessageOptions> {
        let promise = Promise<TCHMessageOptions>()

        self.withBody(body)
        self.withAttributes(attributes) { (result) in
            if result.isSuccessful() {
                promise.resolve(with: self)
            } else if let error = result.error {
                promise.reject(with: error)
            } else {
                promise.reject(with: ClientError.message(detail: "Failed to create options for message."))
            }
        }

        return promise
    }

    func with(mediaItem: MediaItem, attributes: TCHJsonAttributes) -> Future<TCHMessageOptions> {

        let promise = Promise<TCHMessageOptions>()

        self.withAttributes(attributes) { (result) in
            if result.isSuccessful() {
                self.with(mediaItem: mediaItem)
                promise.resolve(with: self)
            } else if let error = result.error {
                promise.reject(with: error)
            } else {
                promise.reject(with: ClientError.message(detail: "Failed to create options for message."))
            }
        }

        return promise
    }

    private func with(mediaItem: MediaItem) {
        guard let data = mediaItem.data else { return }

        let inputStream = InputStream(data: data)
        self.withMediaStream(inputStream,
                             contentType: mediaItem.type.rawValue,
                             defaultFilename: mediaItem.fileName,
                             onStarted: {
                                // Handle started
                                print("Media upload started")
        },
                             onProgress: { (bytes) in
                                // Handle progress
                                print("Media upload progress: \(bytes)")
        }) { (mediaSid) in
            // Handle completion
            print("Media upload completed: \(mediaSid)")
        }
    }
}
