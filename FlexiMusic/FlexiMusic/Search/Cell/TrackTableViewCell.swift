//
//  TrackTableViewCell.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 07.01.2025.
//

import UIKit
import SnapKit
import Kingfisher

// MARK: - TrackTableViewCellViewModel

protocol TrackTableViewCellViewModel {
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
        createLabel(size: 17, textColor: .label)
    }()

    private lazy var artistNameLabel: UILabel = {
        createLabel(size: 13, textColor: .secondaryLabel)
    }()

    private lazy var collectionNameLabel: UILabel = {
        createLabel(size: 13, textColor: .secondaryLabel)
    }()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.kf.cancelDownloadTask()
        trackImageView.image = nil
        trackNameLabel.text = nil
        artistNameLabel.text = nil
        collectionNameLabel.text = nil
    }

    // MARK: - Configuration

    func configure(viewModel: TrackTableViewCellViewModel) {
        trackImageView.kf.setImage(with: viewModel.iconUrl)
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        collectionNameLabel.text = viewModel.collectionName
    }

    // MARK: - Private Methods

    private func setupCell() {
        contentView.addSubviews(
            trackImageView,
            trackNameLabel,
            artistNameLabel,
            collectionNameLabel
        )
        setupConstraints()
    }
}

// MARK: - UI Helper

private extension TrackTableViewCell {

    func createLabel(
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

private extension TrackTableViewCell {

    func setupConstraints() {
        trackImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(21)
            make.centerY.equalToSuperview()
            make.size.equalTo(60)
        }

        trackNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(trackImageView.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(13)
            make.trailing.equalToSuperview().inset(21)
        }

        artistNameLabel.snp.makeConstraints { make in
            make.top.equalTo(trackNameLabel.snp.bottom).offset(2)
            make.leading.trailing.equalTo(trackNameLabel)
        }

        collectionNameLabel.snp.makeConstraints { make in
            make.top.equalTo(artistNameLabel.snp.bottom).offset(3)
            make.leading.trailing.equalTo(trackNameLabel)
        }
    }
}
