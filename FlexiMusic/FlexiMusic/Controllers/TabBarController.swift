//
//  TabBarController.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 05.01.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
}

// MARK: - Private methods
extension TabBarController {
    private func setupViewControllers() {
        guard let searchImage = UIImage(systemName: "magnifyingglass"),
              let libraryImage = UIImage(systemName: "music.note.list") else {
            return
        }
        
        viewControllers = [
            generateViewController(
                rootViewController: SearchTableViewController(),
                image: searchImage,
                title: "Search"
            ),
            generateViewController(
                rootViewController: LibraryViewController(),
                image: libraryImage,
                title: "Library"
            )
        ]
        configureTabBarAppearance()
    }
    
    private func generateViewController(rootViewController: UIViewController,
                                        image: UIImage,
                                        title: String) -> UIViewController {
        
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.title = title
        rootViewController.navigationItem.title = title
        navigationVC.navigationBar.prefersLargeTitles = true
        return navigationVC
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 12)
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemPink,
            .font: UIFont.systemFont(ofSize: 12)
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemPink
        
        tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
