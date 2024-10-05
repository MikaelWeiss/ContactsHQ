//
//  ContactsManager.swift
//  Strive
//
//  Created by Mikael Weiss on 10/20/23.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import Foundation
import Contacts

@MainActor
final class ContactsManager {
    static let shared = ContactsManager()
    
    let CNStore = CNContactStore()
    
    func retreaveContactsList() throws -> [Person] {
        var people = [Person]()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactSocialProfilesKey, CNContactPostalAddressesKey, CNContactUrlAddressesKey , CNContactRelationsKey, CNContactBirthdayKey, CNContactDatesKey, CNContactImageDataKey] as [CNKeyDescriptor] //TODO: Add birthday and dates to Person
        let request = CNContactFetchRequest(keysToFetch: keys)
        do {
            try CNStore.enumerateContacts(with: request) { contact, _ in
                people.append(
                    Person(givenName: contact.givenName,
                           familyName: contact.familyName,
                           phoneNumbers: contact.phoneNumbers.map { Person.LabeledContactValue(label: string(for: $0.label), value: "\($0.value.stringValue)") },
                           emailAddresses: contact.emailAddresses.map { Person.LabeledContactValue(label: string(for: $0.label), value: "\($0.value)") },
                           socialProfiles: contact.socialProfiles.map { Person.LabeledContactValue(label: string(for: $0.label), value: "\($0.value)") },
                           postalAddresses: contact.postalAddresses.map { Person.LabeledContactValue(label: string(for: $0.label), value: "\($0.value)") },
                           urlAddresses: contact.urlAddresses.map { Person.LabeledContactValue(label: string(for: $0.label), value: "\($0.value)") },
                           contactRelations: contact.contactRelations.map { Person.LabeledContactValue(label: string(for: $0.label), value: "\($0.value)") },
                           imageData: contact.imageData,
                           type: .acquaintance,
//                           events: [],
                           groups: []))
            }
        } catch {
            throw AppError.contactsManagerErrorEnumerateContactsFailed
        }
        return people
    }
    private func string(for label: String?) -> String {
        CNLabeledValue<NSString>.localizedString(forLabel: label ?? "")
    }
    
    func fetchAuthorizationNotDetermined() -> Bool {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized, .denied, .restricted, .limited:
            return false
        default:
            return true
        }
    }
    
    func requestAuthorization(_ completionHandler: @escaping (Bool, Error?) -> Void) {
        CNStore.requestAccess(for: .contacts, completionHandler: completionHandler)
    }
}
