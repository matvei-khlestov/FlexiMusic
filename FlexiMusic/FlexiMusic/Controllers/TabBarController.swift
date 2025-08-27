//
//  TabBarController.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 05.01.2025.
//

import UIKit

protocol TabBarControllerDelegate: AnyObject {
    func minimizeTrackDetailController()
    func maximizeTrackDetailController(viewModel: SearchViewModel.Cell?)
}

final class TabBarController: UITabBarController {
    
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    private let searchVC = SearchViewController()
    private let libraryVC = LibraryViewController()
    private let trackDetailView = TrackDetailView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTrackDetailView()
        searchVC.tabBarDelegate = self
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
                rootViewController: searchVC,
                image: searchImage,
                title: "Search"
            ),
            generateViewController(
                rootViewController: libraryVC,
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
    
    private func setupTrackDetailView() {
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
        trackDetailView.tabBarDelegate = self
        trackDetailView.delegate = searchVC
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        
        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        minimizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        bottomAnchorConstraint = trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        
        bottomAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.isActive = true

        trackDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        trackDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
}

extension TabBarController: TabBarControllerDelegate {
    func maximizeTrackDetailController(viewModel: SearchViewModel.Cell?) {
        
        maximizedTopAnchorConstraint.isActive = true
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
            self.view.layoutIfNeeded()
            self.tabBar.alpha = 0
        },
                       completion: nil)
        
        guard let viewModel = viewModel else { return }
        self.trackDetailView.set(viewModel: viewModel)
    }
    
    func minimizeTrackDetailController() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
            self.view.layoutIfNeeded()
            self.tabBar.alpha = 1
        },
                       completion: nil)
    }
}
