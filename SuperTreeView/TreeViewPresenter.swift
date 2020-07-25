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
    
    private var appliedSource: [Model] = (0..<5).map({ _ in .init(levelId: 1, foreignIds: [UUID()]) }) {
        didSet {
            delegate?.sourceDidUpdate(appliedSource)
        }
    }
    
    private func makeSourceAt(levelId: Int, foreignIds: Set<UUID>, count: Int = 3) -> [Model] {
        (0..<count).map { _ in
            .init(levelId: levelId, foreignIds: foreignIds)
        }
    }
}

extension TreeViewPresenter: TreeViewControllerProtocol {
    func viewDidLoad() {
        delegate?.sourceDidUpdate(appliedSource)
    }
    
    func tableViewDidSelect(rowAt indexPath: IndexPath) {
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
                contentsOf: makeSourceAt(levelId: selectedLevelId + 1, foreignIds: selectedForeignIds),
                at: indexPath.row + 1
            )
        }
    }
}

extension TreeViewPresenter {
    struct Model: Identifiable {
        let id = UUID()
        let levelId: Int
        var foreignIds: Set<UUID> = []
        
        var idString: String {
            "id: \(id.uuidString.prefix(2))..."
        }
        
        var levelIdString: String {
            "levelId: \(levelId)"
        }
        
        var foreignIdsString: String {
            "foreignIds: \(foreignIds.map { "\($0.uuidString.prefix(2))" }.joined(separator: ", "))"
        }
        
        var title: String {
            [idString, levelIdString, foreignIdsString].joined(separator: ", ")
        }
    }
}
