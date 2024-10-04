//
//  AddEditPerson.swift
//  Strive
//
//  Created by Mikael Weiss on 10/20/23.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import SwiftUI
import SwiftData

struct AddEditPerson: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @State var editMode = EditMode.active
    private var saveButtonIsDisabled: Bool {
        givenName.isEmpty
    }
    private var navigationTitle: String {
        personToEdit == nil ? addPersonTitleText : fullName
    }
    private var addPersonTitleText: String {
        givenName.isEmpty ? "Add Person" : "\(fullName)"
    }
    private var fullName: String {
        givenName + " " + lastName
    }
    let personToEdit: Person?
    @State private var givenName = ""
    @State private var lastName = ""
    @State private var company = ""
    @State private var phoneNumbers: [LabeledValue] = []
    @State private var emailAddresses: [LabeledValue] = []
    @State private var socialProfiles: [LabeledValue] = []
    @State private var postalAddresses: [LabeledValue] = []
    @State private var websites: [LabeledValue] = []
    @State private var note = ""
    @State private var personType = Person.PersonType.family
    @State private var preferredLanguage: Person.Language?
    @State private var selectedAvailabilitTimes: [Person.Availability] = []
    @State private var birthday = Date()
    @State private var showBirthdayPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                PersonNameAndTypeSection(givenName: $givenName, lastName: $lastName, company: $company, personType: $personType)
                
                LabeledContactValuesList(values: $phoneNumbers, addValueText: "Add phone number", commonLabelType: .phoneNumber)
                LabeledContactValuesList(values: $emailAddresses, addValueText: "Add email address", commonLabelType: .email)
                LabeledContactValuesList(values: $socialProfiles, addValueText: "Add social profile", commonLabelType: .socialProfile)
                LabeledContactValuesList(values: $postalAddresses, addValueText: "Add postal address", commonLabelType: .physicalAddress)
                LabeledContactValuesList(values: $websites, addValueText: "Add websites", commonLabelType: .URL)
                
                personAvailabiltySection
                
                Section {
                    if showBirthdayPicker {
                        HStack {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                                .font(.title2)
                                .onTapGesture(perform: didTapRemoveBirthday)
                            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                        }
                    } else {
                        HStack {
                            Spacer()
                            Button("Add Birthday", action: didTapAddBirthday)
                                .tint(.green)
                            Spacer()
                        }
                    }
                    Picker("Preferred Language", selection: $preferredLanguage) {
                        ForEach(Person.Language.allCases, id: \.self) {
                            Text("\($0.rawValue.capitalized)").tag(Person.Language?($0))
                        }
                        Text("none").tag(Person.Language?(nil))
                    }.pickerStyle(.menu)
                } header: {
                    Text("More")
                }
                .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in 0 })
                
                Section {
                    TextField("Note/Background Information", text: $note, axis: .vertical)
                        .lineLimit(5, reservesSpace: true)
                }
                
                Section {
                    if let person = personToEdit {
                        ForEach(person.groups, id: \.self) {
                            Text($0)
                        }
                    }
//                    NavigationLink(destination: { AddGroupToPerson() }, label: { Text("Add a group +") })
                } header: {
                    Text("Groups")
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(saveButtonIsDisabled)
                }
            }
            .navigationTitle(navigationTitle)
            .onAppear(perform: loadPerson)
            .environment(\.editMode, $editMode)
        }
    }
    
    //MARK: - Subviews
    
    private struct PersonNameAndTypeSection: View {
        @Binding var givenName: String
        @Binding var lastName: String
        @Binding var company: String
        @Binding var personType: Person.PersonType
        
        var body: some View {
            Section {
                TextField("Given Name", text: $givenName)
                TextField("Last Name", text: $lastName)
                TextField("Company", text: $company)
                Picker("Person Type", selection: $personType) {
                    ForEach(Person.PersonType.allCases, id: \.self) {
                        Text("\($0.rawValue.capitalized)").tag($0)
                    }
                }.pickerStyle(.menu)
            }
        }
    }
    
    private var personAvailabiltySection: some View {
        Section {
            ForEach(Person.Availability.allCases, id: \.self) { availability in
                HStack {
                    Text("\(availability.rawValue.capitalized)")
                    Spacer()
                    if selectedAvailabilitTimes.contains(availability) {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selected(availability: availability)
                }
            }
        } header: {
            Text("Availability")
        }
    }
}

//MARK: - Presenting

extension AddEditPerson {
    private func selected(availability: Person.Availability) {
        if !selectedAvailabilitTimes.contains(availability) {
            selectedAvailabilitTimes.append(availability)
        } else {
            selectedAvailabilitTimes.removeAll(where: { $0 == availability })
        }
    }
    
    private struct LabeledContactValuesList: View {
        @Binding var values: [LabeledValue]
        let addValueText: String
        let commonLabelType: CommonLabelType
        @State private var showLabelSheet = false
        @FocusState private var focusedTextField: UUID?
        
        var body: some View {
            Section {
                ForEach($values) { $value in
                    HStack {
                        HStack {
                            Text(value.label)
                                .font(.footnote)
                                .lineLimit(1)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 50)
                        .onTapGesture(perform: { showLabelSheet = true })
                        .sheet(isPresented: $showLabelSheet) {
                            EditContactLabelView(labelValue: $value.label, commonLabelType: commonLabelType)
                        }
                        HStack {
                            TextField(text: $value.value, label: { Text("Value") })
                                .focused($focusedTextField, equals: _value.id)
                            if focusedTextField == _value.id {
                                Image(systemName: "xmark.circle.fill")
                                    .frame(width: 10)
                                    .onTapGesture { value.value = "" }
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete { removeRows(at: $0, in: &values)}
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                    Text(addValueText)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        let nextLabel = nextLabelValue(given: values, in: commonLabelType)
                        values.append(LabeledValue(label: nextLabel, value: ""))
                        focusedTextField = values.last?.id
                    }
                }
            }
        }
        
        private func removeRows(at offsets: IndexSet, in array: inout [LabeledValue]) {
            array.remove(atOffsets: offsets)
        }
        
        private func nextLabelValue(given usedLabels: [LabeledValue], in commonLabelType: CommonLabelType) -> String {
            let usedLabels = usedLabels.map { $0.label }
            var allLabels = [String]()
            switch commonLabelType {
            case .phoneNumber: allLabels = CommonPhoneNumberLabels.allCases.map { $0.rawValue }
            case .email: allLabels = CommonEmailLabels.allCases.map { $0.rawValue }
            case .URL: allLabels = CommonURLAddressLabels.allCases.map { $0.rawValue }
            case .physicalAddress: allLabels = CommonPhysicalAddressLabels.allCases.map { $0.rawValue }
            case .socialProfile: allLabels = CommonSocialProfileLabels.allCases.map { $0.rawValue }
            }
            allLabels.removeAll(where: { usedLabels.contains($0) })
            return allLabels.first ?? ""
        }
    }
}

//MARK: - Interacting

extension AddEditPerson {
    private func didTapAddBirthday() {
        withAnimation {
            showBirthdayPicker = true
        }
    }
    private func didTapRemoveBirthday() {
        withAnimation {
            showBirthdayPicker = false
        }
    }
    
    //MARK: Loading
    
    private func loadPerson() {
        if let personToEdit = personToEdit {
            givenName = personToEdit.givenName
            lastName = personToEdit.familyName ?? ""
            company = personToEdit.company ?? ""
            personType = personToEdit.type
            phoneNumbers = mapToLabeledValue(from: personToEdit.phoneNumbers)
            emailAddresses = mapToLabeledValue(from: personToEdit.emailAddresses)
            socialProfiles = mapToLabeledValue(from: personToEdit.socialProfiles)
            postalAddresses = mapToLabeledValue(from: personToEdit.postalAddresses)
            websites = mapToLabeledValue(from: personToEdit.urlAddresses)
            selectedAvailabilitTimes = personToEdit.availability
            birthday = personToEdit.birthday ?? Date.now
            preferredLanguage = personToEdit.preferredLanguage
            note = personToEdit.note ?? ""
            if personToEdit.birthday != nil {
                showBirthdayPicker = true
            }
        }
    }
    
    private struct LabeledValue: Identifiable, Equatable {
        let id = UUID()
        var label: String
        var value: String
    }
    
    private func mapToLabeledValue(from labeledContactValues: [Person.LabeledContactValue]) -> [LabeledValue] {
        let mappedValues = labeledContactValues.map { LabeledValue(label: $0.label ?? "", value: $0.value)}
        return mappedValues.filter { !$0.value.isEmpty }
    }
    
    //MARK: Saving
    private func save() {
        if var personToEdit = personToEdit {
            update(person: &personToEdit)
        } else {
            var newPerson = Person(givenName: givenName, type: personType)
            update(person: &newPerson)
            context.insert(newPerson)
        }
        dismiss()
    }
    
    private func update(person: inout Person) {
        if !givenName.isEmpty {
            person.givenName = givenName
        }
        if !lastName.isEmpty {
            person.familyName = lastName
        }
        if !company.isEmpty {
            person.company = company
        }
        person.phoneNumbers = mapToLabeledContactValue(from: phoneNumbers)
        person.emailAddresses = mapToLabeledContactValue(from: emailAddresses)
        person.socialProfiles = mapToLabeledContactValue(from: socialProfiles)
        person.postalAddresses = mapToLabeledContactValue(from: postalAddresses)
        person.urlAddresses = mapToLabeledContactValue(from: websites)
        if !note.isEmpty {
            person.note = note
        }
        person.type = personType
        person.preferredLanguage = preferredLanguage
        person.availability = selectedAvailabilitTimes
        if showBirthdayPicker {
            person.birthday = birthday
        }
    }
    
    private func mapToLabeledContactValue(from labeledValues: [LabeledValue]) -> [Person.LabeledContactValue] {
        labeledValues.map { Person.LabeledContactValue(label: $0.label, value: $0.value)}
    }
    
    //MARK: - Common Label Types
    
    enum CommonLabelType {
        case phoneNumber, email, URL, physicalAddress, socialProfile
    }
    enum CommonPhoneNumberLabels: String, CaseIterable {
        case mobile = "mobile"
        case home = "home"
        case work = "work"
        case school = "school"
        case iPhone = "iPhone"
        case appleWatch = "Apple Watch"
        case main = "main"
        case homeFax = "home Fax"
        case workFax = "work Fax"
        case pager = "pager"
        case other = "other"
    }
    enum CommonEmailLabels: String, CaseIterable {
        case home, work, school, iCloud, other
    }
    enum CommonURLAddressLabels: String, CaseIterable {
        case homepage, home, work, school, other
    }
    enum CommonPhysicalAddressLabels: String, CaseIterable {
        case home, work, school, other
    }
    enum CommonSocialProfileLabels: String, CaseIterable {
        case messenger = "Messenger"
        case slack = "Slack"
        case twitter = "Twitter AKA (X)"
        case facebook = "Facebook"
        case flickr = "Flickr"
        case linkedIn = "LinkedIn"
        case myspace = "Myspace"
        case sinaWeibo = "Sina Weibo"
    }
}

#Preview {
    AddEditPerson(personToEdit: Person(givenName: "Johnny", type: .family))
}

