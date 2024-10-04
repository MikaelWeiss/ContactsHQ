//
//  AppErrors.swift
//  Strive
//
//  Created by Mikael Weiss on 10/21/23.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import Foundation

enum AppError: Error {
    
    // MARK: - DefaultErrors
    case `default`
    case fetchFailed
    case saveFailed
    
    // MARK: - ContactsManagerErrors
    case contactsManagerErrorUnknownError
    case contactsManagerErrorRequestAccessThrewError
    case contactsManagerErrorEnumerateContactsFailed
    
    enum RecurrenceHelperError: Error, LocalizedError {
        case foundNil
        case missingValues
        case nextDateFailed
        
        var errorDescription: String? {
            switch self {
                case .foundNil: return "The recurrence failed to load"
                case .missingValues: return "Some part of the recurrence is missing"
                case .nextDateFailed: return "Something went wrong when trying to figure out if a task should occur"
            }
        }
    }
}
