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
        .init(levelId: 1, groupId: 1, id: 1),
        .init(levelId: 1, groupId: 2, id: 1),
        .init(levelId: 1, groupId: 3, id: 1),
        .init(levelId: 1, groupId: 3, id: 2),
        .init(levelId: 1, groupId: 3, id: 3),
        .init(levelId: 1, groupId: 2, id: 2),
        .init(levelId: 1, groupId: 2, id: 3),
        .init(levelId: 2, groupId: 1, id: 2),
        .init(levelId: 3, groupId: 1, id: 3)
    ]
    
    private var appliedSource: [Model] = (0..<5).map({ .init(levelId: $0 + 1, groupId: 1, id: $0 + 1) }) {
        didSet {
            delegate?.sourceDidUpdate(appliedSource)
        }
    }
    
    private func makeModelsAt(levelId: Int, groupId: Int, count: Int) -> [Model] {
        (0..<count).map {
            .init(levelId: levelId, groupId: groupId, id: $0 + 1)
        }
    }
    
    func select(_ indexPath: IndexPath) {
        guard
            indexPath.row >= 0 &&
            appliedSource.count > indexPath.row else { return }
        
        let selectedLevelId = appliedSource[indexPath.row].levelId
        let selectedGroupId = appliedSource[indexPath.row].groupId
        
        if !appliedSource.filter({
            $0.levelId == selectedLevelId &&
            $0.groupId > selectedGroupId
        }).isEmpty {
            appliedSource.removeAll {
                $0.levelId == selectedLevelId &&
                $0.groupId > selectedGroupId
            }
        } else {
            appliedSource.insert(
                contentsOf: makeModelsAt(
                    levelId: selectedLevelId,
                    groupId: selectedGroupId + 1,
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
        let id: Int
        var title: String {
            "Неизвестно levelId: \(levelId) groupId: \(groupId), id: \(id)"
        }
    }
}
