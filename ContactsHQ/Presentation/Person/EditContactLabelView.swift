//
//  EditContactLabelView.swift
//  Strive
//
//  Created by Mikael Weiss on 11/11/23.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import SwiftUI

struct EditContactLabelView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var textFieldValue = ""
    @Binding var labelValue: String
    let commonLabelType: AddEditPerson.CommonLabelType
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(values(for: commonLabelType), id: \.self) { value in
                    HStack {
                        Text(value)
                        Spacer()
                        if labelValue == value {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        didTapCommonLabeledValue(value: value)
                    }
                }
                Section {
                    TextField(text: $textFieldValue, label: { Text("Custom Label") })
                        .onSubmit(didSubmitTextFieldValue)
                }
            }
            .onAppear(perform: loadData)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel", action: didTapCancel)
                }
            }
            .navigationTitle("Label")
        }
    }
}

//MARK: - Interacting
extension EditContactLabelView {
    private func loadData() {
        if !valueIsCommonLabel(value: labelValue, commonLabelType: commonLabelType) {
            textFieldValue = labelValue
        }
    }
    private func didSubmitTextFieldValue() {
        labelValue = textFieldValue
        dismiss()
    }
    private func didTapCommonLabeledValue(value: String) {
        labelValue = value
        dismiss()
    }
    private func didTapCancel() {
        dismiss()
    }
}

//MARK: - Presenting
extension EditContactLabelView {
    private func values(for commonLabelType: AddEditPerson.CommonLabelType) -> [String] {
        switch commonLabelType {
        case .phoneNumber: return AddEditPerson.CommonPhoneNumberLabels.allCases.map { $0.rawValue }
        case .email: return AddEditPerson.CommonEmailLabels.allCases.map { $0.rawValue }
        case .URL: return AddEditPerson.CommonURLAddressLabels.allCases.map { $0.rawValue }
        case .physicalAddress: return AddEditPerson.CommonPhysicalAddressLabels.allCases.map { $0.rawValue }
        case .socialProfile: return AddEditPerson.CommonSocialProfileLabels.allCases.map { $0.rawValue }
        }
    }
    private func valueIsCommonLabel(value: String, commonLabelType: AddEditPerson.CommonLabelType) -> Bool {
        switch commonLabelType {
        case .phoneNumber: return AddEditPerson.CommonPhoneNumberLabels.allCases.contains(where: { $0.rawValue == value })
        case .email: return AddEditPerson.CommonEmailLabels.allCases.contains(where: { $0.rawValue == value })
        case .URL: return AddEditPerson.CommonURLAddressLabels.allCases.contains(where: { $0.rawValue == value })
        case .physicalAddress: return AddEditPerson.CommonPhysicalAddressLabels.allCases.contains(where: { $0.rawValue == value })
        case .socialProfile: return AddEditPerson.CommonSocialProfileLabels.allCases.contains(where: { $0.rawValue == value })
        }
    }
}

#Preview {
    EditContactLabelView(labelValue: .constant(""), commonLabelType: .phoneNumber)
}
