//
//  TrackTableViewCell.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 07.01.2025.
//

import UIKit
import SnapKit
import Kingfisher

// MARK: - TrackTableViewCellProtocol
protocol TrackCellViewModelProtocol {
    var iconUrl: URL? { get }
    var trackName: String { get }
    var artistName: String { get }
    var collectionName: String { get }
}

// MARK: - TrackTableViewCell
final class TrackTableViewCell: UITableViewCell {
    
    // MARK: - Reuse Id
    static let reuseId = "trackCell"
    
    // MARK: - UI Elements
    private lazy var trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var trackNameLabel: UILabel = {
        createLabel(size: 17, textColor: .black)
    }()
    
    private lazy var artistNameLabel: UILabel = {
        createLabel(size: 13, textColor: .secondaryLabel)
    }()
    
    private lazy var collectionNameLabel: UILabel = {
        createLabel(size: 13, textColor: .secondaryLabel)
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    // MARK: - Configuration Cell
    func configure(viewModel: TrackCellViewModelProtocol) {
        trackImageView.kf.setImage(with: viewModel.iconUrl)
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        collectionNameLabel.text = viewModel.collectionName
    }
    
    // MARK: - Private Methods
    private func setupCell() {
        addSubviews(
            trackImageView,
            trackNameLabel,
            artistNameLabel,
            collectionNameLabel
        )
        setupConstraints()
    }
    
    private func addSubviews(_ subviews: UIView...) {
        for subview in subviews {
            addSubview(subview)
        }
    }
}

// MARK: - UI Helper
extension TrackTableViewCell {
    private func createLabel(
        size: CGFloat,
        weight: UIFont.Weight = .medium,
        textColor: UIColor
    ) -> UILabel {
        
        let label = UILabel()
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textColor = textColor
        return label
    }
}

// MARK: - Constraints
extension TrackTableViewCell {
    private func setupConstraints() {
        trackImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().inset(12)
            make.width.height.equalTo(60)
        }
        
        trackNameLabel.snp.makeConstraints { make in
            make.left.equalTo(trackImageView.snp.right).offset(10)
            make.top.equalToSuperview().offset(13)
            make.right.equalToSuperview().inset(21)
        }
        
        artistNameLabel.snp.makeConstraints { make in
            make.top.equalTo(trackNameLabel.snp.bottom).offset(2)
            make.left.equalTo(trackNameLabel.snp.left)
            make.right.equalTo(trackNameLabel.snp.right)
        }
        
        collectionNameLabel.snp.makeConstraints { make in
            make.top.equalTo(artistNameLabel.snp.bottom).offset(3)
            make.left.equalTo(artistNameLabel.snp.left)
            make.right.equalTo(artistNameLabel.snp.right)
        }
    }
}
