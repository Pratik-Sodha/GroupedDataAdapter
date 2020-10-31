//
//  GroupedDataAdapter.swift
//  GroupedDataAdapter
//
//  Created by Pratik Sodha on 28/10/20.
//

//Array adapter class which accept keys and items and manage sortingand filtering.

import Foundation
class GroupedDataAdapter<GroupType : Hashable, ItemType> {
    
    
    let groups : [GroupType]
    let items : [GroupType : [ItemType]]
    
    //-----------------------------------------------------
    //MARK: -
    private(set) var sortedGroups : [GroupType] = []
    private(set) var sortedItems : [GroupType : [ItemType]] = [:]

    private(set) var filteredGroups : [GroupType] = []
    private(set) var filteredItems : [GroupType : [ItemType]] = [:]
    
    private(set) var operationalGroups : [GroupType] = []
    private(set) var operationalItems : [GroupType : [ItemType]] = [:]

    
    //-----------------------------------------------------
    //MARK: - Init
    init(groups : [GroupType], items : [GroupType : [ItemType]]) {
        self.groups = groups
        self.items = items
        invalidate()
    }
    
    //-----------------------------------------------------
    //MARK: - Sorting
    
    var groupSortComparator : ((GroupType,GroupType) -> Bool)? {
        didSet {
            invalidate()
        }
    }
    
    var itemSortComparator : ((ItemType,ItemType) -> Bool)? {
        didSet {
            invalidate()
        }
    }
    
    func groupSortComparator(groupSortComparator : ((GroupType,GroupType) -> Bool)?, itemSortComparator: ((ItemType,ItemType) -> Bool)?) {
        self.groupSortComparator = groupSortComparator
        self.itemSortComparator = itemSortComparator
    }
    
    //-----------------------------------------------------
    //MARK: - Filtering
    
    var filterBlock : (([ItemType]) -> [ItemType])? {
        didSet {
            invalidate()
        }
    }


    
    //-----------------------------------------------------
    //MARK:- Private
    private func invalidate() {
        invalidateSorting()
        invalidateFiltering()
        invalidateOperationalData()
    }

    private func invalidateSorting()  {
        
        if let groupSortComparator = groupSortComparator {
            sortedGroups = groups.sorted(by: groupSortComparator)
        }else {
            sortedGroups = groups
        }
        
        if let itemSortComparator = itemSortComparator {
            sortedItems = items.mapValues({ (items) -> [ItemType] in
                return items.sorted(by: itemSortComparator)
            })
       
        }else {
            sortedItems = items
        }

    }
    
    private func invalidateFiltering() {
        guard let filterBlock = filterBlock else {
            filteredGroups = groups
            filteredItems = items
            return
        }

        filteredItems =  items.compactMapValues { (items) -> [ItemType]? in
            let filtered = filterBlock(items)
            return filtered.count != 0 ? filtered : nil
        }
        filteredGroups = filteredItems.keys.map{$0}
        
    }
    
    private func invalidateOperationalData() {
        
        if let itemSortComparator = itemSortComparator {
            operationalItems = filteredItems.mapValues({ (items) -> [ItemType] in
                return items.sorted(by: itemSortComparator)
            })
       
        }else {
            operationalItems = filteredItems
        }
        
        let group = operationalItems.keys.map{$0}
        if let groupSortComparator = groupSortComparator {
            operationalGroups = group.sorted(by: groupSortComparator)
        }else {
            operationalGroups = group
        }
        
    }
}

//-----------------------------------------------------
//MARK: - Proxy
extension GroupedDataAdapter {
    var isEmpty : Bool { operationalGroups.count == 0 }
    
    func groupIndex(group : GroupType) -> Int? {
        operationalGroups.firstIndex(of: group)
    }
}


//-----------------------------------------------------
//MARK: -

//To convert sequnce value into dictinory.
//Return a tupple of keys and dictinory of sequnce value.
public extension Sequence {
    func adapterGrouping<U: Hashable>(by key: (Element) -> U) -> (keys : [U], values : [U:[Element]]) {
        var hash: [U: [Element]] = [:]
        
        for element : Element in self {
            let key = key(element)
            if case nil = hash[key]?.append(element) {
                let array : [Element] = [element]
                hash[key] = array
            }
        }
        return (hash.keys.map {$0},hash)
    }
}
