//
//  Person.swift
//  ContactsHQ
//
//  Created by Mikael Weiss on 10/3/24.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Person {
    private(set) var id = UUID()
    var givenName = ""
    var familyName: String?
    var company: String?
    var phoneNumbers = [LabeledContactValue]()
    var emailAddresses = [LabeledContactValue]()
    var socialProfiles = [LabeledContactValue]()
    var postalAddresses = [LabeledContactValue]()
    var urlAddresses = [LabeledContactValue]()
    var contactRelations = [LabeledContactValue]()
    var note: String?
    var imageData: Data?
    var type = PersonType.acquaintance
    var preferredLanguage: Language?
    var availability = [Availability]()
    var birthday: Date?
//    @Relationship(inverse: \Event.associatedPeople) var events: [Event]? = []
    var groups = [String]()
    
    init(id: UUID = UUID(),
         givenName: String,
         familyName: String? = nil,
         company: String? = nil,
         phoneNumbers: [LabeledContactValue] = [],
         emailAddresses: [LabeledContactValue] = [],
         socialProfiles: [LabeledContactValue] = [],
         postalAddresses: [LabeledContactValue] = [],
         urlAddresses: [LabeledContactValue] = [],
         contactRelations: [LabeledContactValue] = [],
         note: String? = nil,
         imageData: Data? = nil,
         type: PersonType,
         preferredLanguage: Language? = nil,
         availability: [Availability] = [],
         birthday: Date? = nil,
//         events: [Event] = [],
         groups: [String] = []) {
        
        self.givenName = givenName
        self.familyName = familyName
        self.company = company
        self.phoneNumbers = phoneNumbers
        self.emailAddresses = emailAddresses
        self.socialProfiles = socialProfiles
        self.postalAddresses = postalAddresses
        self.urlAddresses = urlAddresses
        self.note = note
        self.imageData = imageData
        self.type = type
        self.preferredLanguage = preferredLanguage
        self.availability = availability
        self.contactRelations = contactRelations
        self.birthday = birthday
//        self.events = events
        self.groups = groups
    }
    
    enum PersonType: String, CaseIterable, Codable {
        case family, friend, acquaintance, business, client
    }
    
    enum Language: String, CaseIterable, Codable {
        case english, spanish
    }

    enum Availability: String, CaseIterable, Codable {
        case morning, evening, night
    }

    struct LabeledContactValue: Codable, Equatable {
        let label: String?
        let value: String
        
        init(label: String, value: String) {
            self.label = label
            self.value = value
        }
    }
}
