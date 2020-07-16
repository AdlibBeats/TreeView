//
//  TreeViewController.swift
//  SuperTreeView
//
//  Created by Andrew on 14.07.2020.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

protocol TreeViewControllerProtocol: class {
    func viewDidLoad()
}

final class TreeViewController: UIViewController {
    final class TreeViewCell: UITableViewCell {
        private let label = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 15)
            $0.textColor = .black
        }
        
        private lazy var labelLeadingConstraint = label.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: 20
        )
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.addSubview(label)
            [
                labelLeadingConstraint,
                label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                label.trailingAnchor.constraint(
                    lessThanOrEqualTo: contentView.trailingAnchor,
                    constant: -20
                )
            ].forEach { $0.isActive = true }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var model: TreeViewPresenter.Model? {
            willSet {
                labelLeadingConstraint.constant = CGFloat((newValue?.groupId ?? 1) * 20)
                label.text = newValue?.title
                // MARK: disable animation
                //UIView.animate(withDuration: 0.3) { [weak self] in
                // self?.layoutIfNeeded()
                //}
            }
        }
    }
    
    private let tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 56
        $0.allowsSelection = true
        $0.backgroundColor = .white
        $0.bouncesZoom = false
        $0.showsHorizontalScrollIndicator = false
        $0.register(TreeViewCell.self, forCellReuseIdentifier: "\(TreeViewCell.self)")
    }
    
    private weak var delegate: TreeViewControllerProtocol?
    private lazy var presenter = TreeViewPresenter(delegate: self)
    
    private var source: [TreeViewPresenter.Model] = [] {
        didSet {
            // MARK: disable animation
            //tableView.reloadSections([0], with: .fade)
            UIView.performWithoutAnimation {
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        
        func setConstraints() {
            view.addSubview(tableView)
            
            [
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ].forEach { $0.isActive = true }
        }
        
        setConstraints()
        
        delegate = presenter
        delegate?.viewDidLoad()
    }
}

extension TreeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.select(indexPath)
    }
}

extension TreeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        source.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(TreeViewCell.self)", for: indexPath)
        guard let treeViewCell = cell as? TreeViewCell else { return cell }
        
        treeViewCell.model = source[indexPath.row]
        
        return treeViewCell
    }
}

extension TreeViewController: TreeViewPresenterProtocol {
    func sourceDidUpdate(_ source: [TreeViewPresenter.Model]) {
        self.source = source
    }
}
