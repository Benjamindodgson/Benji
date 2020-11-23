//
//  ContactsManager.swift
//  Benji
//
//  Created by Benji Dodgson on 6/30/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Contacts

enum ContactsFetchResult {
    case success(response: [CNContact])
    case error(error: Error)
}

enum ContactPredicateType {
    case name(String)
    case phone(String)
    case email(String)
    case identifier(String)
}

class ContactsManager: NSObject {

    static let shared = ContactsManager()

    let store = CNContactStore()
    let keysToFetch = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        CNContactPhoneNumbersKey,
        CNContactThumbnailImageDataKey,
        CNContactEmailAddressesKey,
        CNContactImageDataAvailableKey,
        CNContactImageDataKey,
        CNContactBirthdayKey,
        CNContactPostalAddressesKey,
        CNContactRelationsKey] as! [CNKeyDescriptor]

    func getAuthorizationStatus(completion: @escaping (CNAuthorizationStatus) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        completion(authorizationStatus)
    }

    func requestForAccess(completion: @escaping CompletionHandler) {
        self.store.requestAccess(for: CNEntityType.contacts,
                                 completionHandler: { (access, accessError) -> Void in
                                    completion(access, accessError)
        })
    }

    fileprivate let contactStoreQueue = DispatchQueue(label: Bundle.main.bundleIdentifier!+".MGCContactStore",
                                                      attributes: DispatchQueue.Attributes.concurrent)

    func getContacts(removeMe: Bool = true, withCompletion completion: @escaping(_ contacts: [CNContact]) -> Void) {

        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)

        var results: [CNContact] = []

        switch authorizationStatus {
        case .notDetermined:
            CNContactStore().requestAccess(for: CNEntityType.contacts) { (allowed, errors) in
                if allowed {
                    self.getContacts(withCompletion: completion)
                }

                runMain {
                    return completion([])
                }
            }
        case .restricted:
            runMain {
                completion([])
            }
        case .denied:
            runMain {
                completion([])
            }
        case .authorized:
            // Fetch the contacts off the main thread so we don't block the UI
            self.contactStoreQueue.async {
                do {
                    let contactsFetchRequest = CNContactFetchRequest(keysToFetch: self.keysToFetch)
                    contactsFetchRequest.sortOrder = .familyName
                    try CNContactStore().enumerateContacts(with: contactsFetchRequest, usingBlock: { (contact, error) in
                        if contact.phoneNumbers.count > 0 {
                            results.append(contact)
                        }
                    })

                } catch {
                    print("Error fetching contact")
                }

                // Once the contacts are retrieved, call the completion block on the main thread to avoid up updating UI off main
                runMain {
                    var finalResults: [CNContact] = []
                    if removeMe, let phone = User.current()?.phoneNumber?.formatPhoneNumber()?.removeAllNonNumbers() {
                        finalResults = results.filter { (contact) -> Bool in
                            if let contactPhone = contact.primaryPhoneNumber?.removeAllNonNumbers() {
                                if contactPhone == phone {
                                    return false
                                } else {
                                    return true
                                }
                            } else {
                                return false
                            }
                        }
                    } else {
                        finalResults = results.filter({ (contact) -> Bool in
                            if let _ = contact.primaryPhoneNumber {
                                return true
                            } else {
                                return false
                            }
                        })
                    }
                    completion(finalResults)
                }
            }
        @unknown default:
            break
        }
    }

    func searchForContact(with predicateType: ContactPredicateType, completionHandler: @escaping (_ result: ContactsFetchResult) -> ()) {

        let contactStore: CNContactStore = CNContactStore()
        var contacts: [CNContact] = [CNContact]()
        let predicate: NSPredicate
        switch predicateType {
        case .name(let name):
            predicate = CNContact.predicateForContacts(matchingName: name)
        case .email(let email):
            predicate = CNContact.predicateForContacts(matchingEmailAddress: email)
        case .phone(let phone):
            let cnNumber = CNPhoneNumber.init(stringValue: phone)
            predicate = CNContact.predicateForContacts(matching: cnNumber)
        case .identifier(let identifier):
            predicate = CNContact.predicateForContacts(withIdentifiers: [identifier])
        }

        do {
            contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
            completionHandler(ContactsFetchResult.success(response: contacts))
        } catch {
            completionHandler(ContactsFetchResult.error(error: error))
        }
    }
}
