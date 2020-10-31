//
//  GroupSortOption.swift
//  GroupedDataAdapter
//
//  Created by APPLE on 29/10/20.
//

import Foundation

enum GroupSortOption : CaseIterable {
    
    case `default`
    case nameAscending
    case nameDescending
    
    var buttonTitle : String {
        switch self {
        case .default:
            return "Sort Group"
        case .nameAscending:
            return "Group(⤵)"
        case .nameDescending:
            return "Group(⤴)"
        }
    }
}

extension GroupSortOption {
    
    mutating func  next()  {
        switch self {
        case .default:
            self = .nameAscending
        case .nameAscending:
            self = .nameDescending
        case .nameDescending:
            self = .default
        }
    }
    
    var sortDescriptor : ((String, String) -> Bool)? {
        switch self {
        case .default:
            return nil
        case .nameAscending:
            return { lhs, rhs in
                lhs < rhs
            }
        case .nameDescending:
            return {$0 > $1}
        }
    }
}
