//
//  FooterView.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 07.01.2025.
//

import UIKit
import SnapKit

final class FooterView: UIView {
    
    // MARK: - UI Elements
    private lazy var footerlabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()
    
    private lazy var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.style = .medium
        loader.hidesWhenStopped = true
        return loader
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Public Methods
    func showLoader() {
        loader.startAnimating()
        footerlabel.text = "LOADING"
    }
    
    func hideLoader() {
        loader.stopAnimating()
        footerlabel.text = ""
    }
    
    // MARK: - Private Methods
    private func setupView() {
        addSubviews(loader, footerlabel)
        
        setupConstraints()
    }
    
    private func addSubviews(_ subviews: UIView...) {
        for subview in subviews {
            addSubview(subview)
        }
    }
}

// MARK: - Constraints
extension FooterView {
    private func setupConstraints() {
        loader.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().inset(20)
        }
        
        footerlabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(loader.snp.bottom).offset(8)
        }
    }
}
