//
//  Reservation.swift
//  Benji
//
//  Created by Benji Dodgson on 5/9/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures
import LinkPresentation
import Branch

enum ReservationKey: String {
    case user
    case createdBy
    case position
    case isClaimed
    case reservationId
}

final class Reservation: PFObject, PFSubclassing {

    static func parseClassName() -> String {
        return String(describing: self)
    }

    var isClaimed: Bool {
        return self.getObject(for: .isClaimed) ?? false
    }

    var position: Int? {
        return self.getObject(for: .position)
    }

    var user: User? {
        return self.getObject(for: .user)
    }

    var createdBy: User? {
        return self.getObject(for: .createdBy)
    }

    static func getReservations(for user: User) -> Future<[Reservation]> {
        let promise = Promise<[Reservation]>()
        if let query = Reservation.query() {
            query.whereKey(ReservationKey.createdBy.rawValue, equalTo: user)
            query.findObjectsInBackground { (objects, error) in
                if let reservations = objects as? [Reservation] {
                    promise.resolve(with: reservations)
                } else if let e = error {
                    promise.reject(with: e)
                } else {
                    promise.reject(with: ClientError.generic)
                }
            }
        } else {
            promise.reject(with: ClientError.generic)
        }
        
        return promise
    }

    static func getFirstUnclaimed(for user: User) -> Future<Reservation> {
        let promise = Promise<Reservation>()
        if let query = Reservation.query() {
            query.whereKey(ReservationKey.createdBy.rawValue, equalTo: user)
            query.whereKey(ReservationKey.isClaimed.rawValue, equalTo: false)
            query.findObjectsInBackground { (objects, error) in
                if let reservations = objects as? [Reservation], let first = reservations.first {
                    promise.resolve(with: first)
                } else if let e = error {
                    promise.reject(with: e)
                } else {
                    promise.reject(with: ClientError.generic)
                }
            }
        } else {
            promise.reject(with: ClientError.generic)
        }

        return promise
    }
}

extension Reservation: Objectable {
    typealias KeyType = ReservationKey

    func getObject<Type>(for key: ReservationKey) -> Type? {
        return self.object(forKey: key.rawValue) as? Type
    }

    func setObject<Type>(for key: ReservationKey, with newValue: Type) {
        self.setObject(newValue, forKey: key.rawValue)
    }

    func getRelationalObject<PFRelation>(for key: ReservationKey) -> PFRelation? {
        return self.relation(forKey: key.rawValue) as? PFRelation
    }
}

extension Reservation: ManageableCellItem {
    var id: String {
        return self.objectId!
    }
}

private var reservationMetadataKey: UInt8 = 0
private var linkKey: UInt8 = 0
extension Reservation: UIActivityItemSource {

    private(set) var metadata: LPLinkMetadata? {
        get {
            return self.getAssociatedObject(&reservationMetadataKey)
        }
        set {
            self.setAssociatedObject(key: &reservationMetadataKey, value: newValue)
        }
    }

    private(set) var link: String? {
        get {
            return self.getAssociatedObject(&linkKey)
        }
        set {
            self.setAssociatedObject(key: &linkKey, value: newValue)
        }
    }

    func prepareMetaData() -> Future<Void> {
        let promise = Promise<Void>()
        let metadataProvider = LPMetadataProvider()

        self.link = self.generateBranchLink().getShortUrl(with: self.generateBranchProperties())
        if let linkString = self.link, let url = URL(string: linkString) {
            metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
                if let e = error {
                    promise.reject(with: e)
                } else {
                    self.metadata = metadata
                    promise.resolve(with: ())
                }
            }
        } else {
            promise.reject(with: ClientError.generic)
        }

        return promise
    }

    func generateBranchLink() -> BranchUniversalObject {

        let canonicalIdentifier = UUID().uuidString
        let buo = BranchUniversalObject(canonicalIdentifier: canonicalIdentifier)
        buo.canonicalUrl = "https://testflight.apple.com/join/w3CExYsD"
        buo.title = "Join the Benji beta"
        buo.contentDescription = "Available on iOS"
        buo.imageUrl = "https://is5-ssl.mzstatic.com/image/thumb/Purple123/v4/51/ca/70/51ca7064-0f75-9e7c-dfc3-1d3afaf9eaa3/AppIcon-0-1x_U007emarketing-0-7-0-85-220.png/1920x1080bb-80.png"
        buo.contentMetadata.customMetadata[ReservationKey.reservationId.rawValue] = self.id
        buo.contentMetadata.customMetadata[ReservationKey.createdBy.rawValue] = self.createdBy?.id
        buo.contentMetadata.customMetadata["target"] = DeepLinkTarget.reservation.rawValue

        return buo
    }

    func generateBranchProperties() -> BranchLinkProperties {
        let properties = BranchLinkProperties()
        properties.addControlParam("$ios_url", withValue: "https://testflight.apple.com/join/w3CExYsD")
        properties.addControlParam("$canonical_url", withValue: "https://testflight.apple.com/join/w3CExYsD")
        return properties
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return URL(string: self.link!)!
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard let link = self.link else { return nil }
        return "Claim your reservation by tapping 👇\n\(link)"
    }

    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        return self.metadata
    }
}

