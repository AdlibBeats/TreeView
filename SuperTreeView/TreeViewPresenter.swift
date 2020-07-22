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
    
    private var appliedSource: [Model] = (0..<5).enumerated().map({ .init(id: $1 + 11, levelId: 1, foreignIds: [0]) }) {
        didSet {
            delegate?.sourceDidUpdate(appliedSource)
        }
    }
    
    private func makeSourceAt(id: Int, levelId: Int, foreignIds: Set<Int>, count: Int) -> [Model] {
        (id..<(id + count)).enumerated().map {
            .init(id: $1 + 10, levelId: levelId, foreignIds: foreignIds)
        }
    }
    
    func select(_ indexPath: IndexPath) {
        guard
            indexPath.row >= 0 &&
            appliedSource.count > indexPath.row else { return }
        
        let selectedAppliedSource = appliedSource[indexPath.row]
        let selectedId = selectedAppliedSource.id
        let selectedLevelId = selectedAppliedSource.levelId
        var selectedForeignIds = selectedAppliedSource.foreignIds
        
        if !appliedSource.filter({
            $0.levelId > selectedLevelId &&
            $0.foreignIds.contains(selectedId) &&
            $0.foreignIds.intersection(selectedForeignIds).count == selectedLevelId
        }).isEmpty {
            appliedSource.removeAll {
                $0.levelId > selectedLevelId &&
                $0.foreignIds.contains(selectedId) &&
                $0.foreignIds.intersection(selectedForeignIds).count == selectedLevelId
            }
        } else {
            selectedForeignIds.insert(selectedId)
            appliedSource.insert(
                contentsOf: makeSourceAt(
                    id: selectedId + 1,
                    levelId: selectedLevelId + 1,
                    foreignIds: selectedForeignIds,
                    count: 3
                ), at: indexPath.row + 1
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
        let id: Int
        let levelId: Int
        var foreignIds: Set<Int> = []
        
        var title: String {
            "id: \(id), levelId: \(levelId), foreignIds: \(foreignIds.map { "\($0)" }.joined(separator: ", "))"
        }
    }
}

extension TreeViewPresenter.Model: Hashable {
    static func == (lhs: TreeViewPresenter.Model, rhs: TreeViewPresenter.Model) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
