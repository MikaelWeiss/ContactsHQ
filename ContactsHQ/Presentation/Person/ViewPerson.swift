//
//  ViewPerson.swift
//  ContactsHQ
//
//  Created by Mikael Weiss on 10/4/24.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import SwiftUI

@MainActor
struct ViewPerson: View {
    @Environment(\.editMode) private var editMode
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }
    @State private var selectedImageData: Data?
    @State private var sourceType: SourceTypeWrapper?
    @State private var selectedImage: UIImage? = nil
    @State private var showAddImageAlert = false
    @State private var showRemoveImageAlert = false
    @FocusState private var focusedField: Int?
    @Bindable var person: Person
    @State private var email = ""
    private var isValidEmail: Bool {
        let emailFormat = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
    @State private var showSelectTraining = false
    @State private var showSelectTeam = false
    @State private var showConfirmRemoveTeam = false
    
    init(person: Person? = nil) {
        if let person {
            self.person = person
        } else {
            let newPerson = Person(givenName: "", type: .acquaintance)
            StorageManager.shared.insert(newPerson)
            self.person = newPerson
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if let image = selectedImage ?? selectedImageData.flatMap(UIImage.init) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100.0, height: 100.0)
                        .clipShape(Circle())
                        .contentShape(Rectangle())
                        .overlay(
                            Image(systemName: "pencil.circle.fill")
                                .padding([.bottom, .trailing], 4)
                                .foregroundStyle(.accent)
                                .opacity(isEditing == true ? 1 : 0),
                            alignment: .bottomTrailing)
                        .onTapGesture {
                            if isEditing == true {
                                showRemoveImageAlert = true
                            } else {
                                editMode?.wrappedValue = .active
                                showRemoveImageAlert = true
                            }
                        }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .opacity(0.5)
                        .frame(width: 100.0, height: 100.0)
                        .contentShape(Rectangle())
                        .overlay(
                            Image(systemName: "pencil.circle.fill")
                                .padding([.bottom, .trailing], 4)
                                .foregroundStyle(.accent)
                                .opacity(isEditing == true ? 1 : 0),
                            alignment: .bottomTrailing)
                        .onTapGesture {
                            if isEditing == true {
                                showAddImageAlert = true
                            } else {
                                editMode?.wrappedValue = .active
                                showAddImageAlert = true
                            }
                        }
                }
                
                if isEditing == true {
                    TextField("Name", text: $person.givenName)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .overlay(
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.accent)
                                .padding(.trailing)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    person.givenName = ""
                                    focusedField = 1
                                }
                                .opacity(isEditing ? 1 : 0)
                            , alignment: .trailing)
                        .focused($focusedField, equals: 1)
                        .onChange(of: focusedField) { oldValue, newValue in
                            if newValue == 1 || newValue == 2 {
                                editMode?.wrappedValue = .active
                            }
                        }
                    
                    TextField("Family Name", text: Binding(get: {
                        person.familyName ?? ""
                    }, set: { newValue in
                        if newValue.isEmpty {
                            person.familyName = nil
                        } else {
                            person.familyName = newValue
                        }
                    }))
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .overlay(
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.accent)
                                .padding(.trailing)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    person.familyName = ""
                                    focusedField = 2
                                }
                                .opacity(isEditing ? 1 : 0)
                            , alignment: .trailing)
                        .focused($focusedField, equals: 2)
                    
                } else {
                    Text(person.givenName + " " + (person.familyName ?? ""))
                        .font(.title)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editMode?.wrappedValue = .active
                            focusedField = 1
                        }
                }
            }
        }
        .onChange(of: editMode?.wrappedValue) { oldValue, newValue in
            person.givenName = person.givenName.trimmingCharacters(in: .whitespaces)
            if let familyName = person.familyName {
                person.familyName = familyName.trimmingCharacters(in: .whitespaces)
            }
            if newValue == .inactive {
                focusedField = nil
            }
        }
        .animation(nil, value: editMode?.wrappedValue)
        .toolbar {
            EditButton()
        }
        .confirmationDialog("Remove Image?",
                            isPresented: $showRemoveImageAlert) {
            Button(role: .destructive) {
                selectedImageData = nil
                selectedImage = nil
            } label: {
                Text("Remove Image")
            }
        } message: {
            Text("Are you sure you want to remove this image? This action cannot be undone.")
        }
        .confirmationDialog("Add Image",
                            isPresented: $showAddImageAlert) {
            Button {
                sourceType = .init(sourceType: .photoLibrary)
            } label: {
                Text("Add from library")
            }
            Button {
                sourceType = .init(sourceType: .camera)
            } label: {
                Text("Take image")
            }
        } message: {
            Text("Add an image")
        }
        .sheet(item: $sourceType) { item in
            ImagePicker(sourceType: item.sourceType, selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            person.imageData = newValue?.pngData()
        }
        .onAppear {
            selectedImageData = person.imageData
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    private struct SourceTypeWrapper: Identifiable {
        let id = UUID()
        let sourceType: UIImagePickerController.SourceType
    }
}

#Preview {
    NavigationView {
        ViewPerson(person: Person.examplePerson)
    }
}
