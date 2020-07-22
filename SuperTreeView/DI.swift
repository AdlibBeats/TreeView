//
//  DI.swift
//  SuperTreeView
//
//  Created by Andrew on 22.07.2020.
//  Copyright © 2020 Andrew. All rights reserved.
//

import Swinject
import Then

enum ContainerError: Error {
    case unwrapped
}

// MARK: Then
extension Container: Then { }

enum Module: String {
    case treeView
}

extension Container {
    static let shared = Container().with {
        $0.register(UINavigationController.self, name: Module.treeView.rawValue) { _ in
            UINavigationController(
                rootViewController: TreeViewController().with {
                    $0.delegate = TreeViewPresenter(delegate: $0)
                }
            )
        }
    }
    
    func resolve<Service>(_ serviceType: Service.Type, module: Module) throws -> Service {
        guard let resolver = resolve(serviceType, name: module.rawValue) else { throw ContainerError.unwrapped }
        return resolver
    }
    
    func resolve(module: Module) throws -> UIViewController {
        switch module {
        case .treeView:
            return try resolve(UINavigationController.self, module: module)
        }
    }
}
