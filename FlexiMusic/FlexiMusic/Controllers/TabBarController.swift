//
//  TabBarController.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 05.01.2025.
//

import UIKit
import SnapKit

protocol TabBarControllerDelegate: AnyObject {
    func minimizeTrackDetailController()
    func maximizeTrackDetailController(viewModel: SearchViewModel.Cell?)
}

final class TabBarController: UITabBarController {
    
    // MARK: - Dependencies
    
    private let searchVC = SearchViewController()
    private let libraryVC = LibraryViewController()
    
    private let trackPlayerService: TrackPlayerServiceProtocol
    private lazy var trackDetailView = TrackDetailView(playerService: trackPlayerService)
    
    // MARK: - Constraints
    
    private var trackDetailTopConstraint: Constraint?
    private var trackDetailBottomConstraint: Constraint?
    
    private var didApplyInitialHiddenPosition = false
    
    // MARK: - Constants
    
    private let minimizedHeight: CGFloat = 64
    
    // MARK: - Init
    
    init(trackPlayerService: TrackPlayerServiceProtocol = TrackPlayerService()) {
        self.trackPlayerService = trackPlayerService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.trackPlayerService = TrackPlayerService()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupViewControllers()
        setupTrackDetailView()
        searchVC.tabBarDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyInitialHiddenPositionIfNeeded()
    }
}

// MARK: - Setup

private extension TabBarController {
    
    func setupViewControllers() {
        guard let searchImage = UIImage(systemName: "magnifyingglass"),
              let libraryImage = UIImage(systemName: "music.note.list") else {
            return
        }
        
        viewControllers = [
            makeTab(rootViewController: searchVC, image: searchImage, title: "Search"),
            makeTab(rootViewController: libraryVC, image: libraryImage, title: "Library")
        ]
        
        configureTabBarAppearance()
    }
    
    func makeTab(rootViewController: UIViewController, image: UIImage, title: String) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.title = title
        rootViewController.navigationItem.title = title
        navigationVC.navigationBar.prefersLargeTitles = true
        return navigationVC
    }
    
    func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
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
        tabBar.isTranslucent = false
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    func setupTrackDetailView() {
        trackDetailView.tabBarDelegate = self
        trackDetailView.delegate = searchVC
        
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        
        trackDetailView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            
            self.trackDetailTopConstraint = make.top.equalToSuperview().offset(0).constraint
            self.trackDetailBottomConstraint = make.bottom.equalToSuperview().offset(0).constraint
        }
    }
    
    func applyInitialHiddenPositionIfNeeded() {
        guard !didApplyInitialHiddenPosition else { return }
        didApplyInitialHiddenPosition = true
        
        let height = view.bounds.height
        trackDetailTopConstraint?.update(offset: height)
        trackDetailBottomConstraint?.update(offset: height)
        
        view.layoutIfNeeded()
    }
    
    func animateLayoutChanges(_ changes: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: changes,
            completion: nil
        )
    }
    
    func minimizedTopOffset() -> CGFloat {
        tabBar.frame.minY - minimizedHeight
    }
}

// MARK: - TabBarControllerDelegate

extension TabBarController: TabBarControllerDelegate {
    
    func maximizeTrackDetailController(viewModel: SearchViewModel.Cell?) {
        trackDetailTopConstraint?.update(offset: 0)
        trackDetailBottomConstraint?.update(offset: 0)
        
        animateLayoutChanges {
            self.view.layoutIfNeeded()
            self.tabBar.alpha = 0
            self.trackDetailView.minimalTrackDetailsView.alpha = 0
            self.trackDetailView.mainTrackDetailStackView.alpha = 1
        }
        
        guard let viewModel else { return }
        trackDetailView.set(viewModel: viewModel)
    }
    
    func minimizeTrackDetailController() {
        trackDetailTopConstraint?.update(offset: minimizedTopOffset())
        
        let height = view.bounds.height
        trackDetailBottomConstraint?.update(offset: height)
        
        animateLayoutChanges {
            self.view.layoutIfNeeded()
            self.tabBar.alpha = 1
            self.trackDetailView.minimalTrackDetailsView.alpha = 1
            self.trackDetailView.mainTrackDetailStackView.alpha = 0
        }
    }
}
