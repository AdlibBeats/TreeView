//
//  TreeViewPresenter.swift
//  SuperTreeView
//
//  Created by Andrew on 15.07.2020.
//  Copyright © 2020 Andrew. All rights reserved.
//

import Foundation

protocol TreeViewPresenterProtocol: class {
    func sourceDidUpdate(_ source: [TreeViewPresenter.Model])
}

final class TreeViewPresenter {
    private weak var delegate: TreeViewPresenterProtocol?
    
    init(delegate: TreeViewPresenterProtocol) {
        self.delegate = delegate
    }
    
    private let allSource: [Model] = [
        .init(levelId: 1, groupId: 1, rowId: 1, id: 1),
        .init(levelId: 1, groupId: 2, rowId: 1, id: 2),
        .init(levelId: 1, groupId: 3, rowId: 2, id: 3),
        .init(levelId: 1, groupId: 3, rowId: 2, id: 4),
        .init(levelId: 1, groupId: 3, rowId: 2, id: 5),
        .init(levelId: 1, groupId: 2, rowId: 1, id: 3),
        .init(levelId: 1, groupId: 2, rowId: 1, id: 4),
        .init(levelId: 2, groupId: 1, rowId: 1, id: 2),
        .init(levelId: 3, groupId: 1, rowId: 1, id: 3)
    ]
    
    private var appliedSource: [Model] = (0..<5).enumerated().map(
        { .init(levelId: $1 + 1, groupId: 1, rowId: 1, id: $1 + 1) }
    ) {
        didSet {
            delegate?.sourceDidUpdate(appliedSource)
        }
    }
    
    private func makeModelsAt(levelId: Int, groupId: Int, rowId: Int, id: Int, count: Int) -> [Model] {
        return (id..<(id + count)).enumerated().map {
            return .init(levelId: levelId, groupId: groupId, rowId: rowId, id: $1)
        }
    }
    
    func select(_ indexPath: IndexPath) {
        guard
            indexPath.row >= 0 &&
            appliedSource.count > indexPath.row else { return }
        
        let selectedAppliedSource = appliedSource[indexPath.row]
        let selectedLevelId = selectedAppliedSource.levelId
        let selectedGroupId = selectedAppliedSource.groupId
        let selectedId = selectedAppliedSource.id
        
        if !appliedSource.filter({
            $0.levelId == selectedLevelId &&
            $0.groupId > selectedGroupId &&
            $0.rowId == selectedId
        }).isEmpty {
            appliedSource.removeAll {
                $0.levelId == selectedLevelId && $0.groupId > selectedGroupId && $0.rowId == selectedId
            }
        } else {
            appliedSource.insert(
                contentsOf: makeModelsAt(
                    levelId: selectedLevelId,
                    groupId: selectedGroupId + 1,
                    rowId: selectedId,
                    id: selectedId + 1,
                    count: 3),
                at: indexPath.row + 1
            )
        }
    }
}

extension TreeViewPresenter: TreeViewControllerProtocol {
    func viewDidLoad() {
        delegate?.sourceDidUpdate(appliedSource)
    }
}

extension TreeViewPresenter {
    struct Model {
        let levelId: Int
        let groupId: Int
        let rowId: Int
        let id: Int
        var title: String {
            "levelId: \(levelId) groupId: \(groupId), rowId: \(rowId) id: \(id)"
        }
    }
}
