//
//  TrackDetailView.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 03.08.2025.
//

import UIKit
import SnapKit

final class TrackDetailView: UIView {
    
    // MARK: - UI Elements
    
    private lazy var slideDownHandleButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 34, weight: .regular)
        button.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        button.setImage(UIImage(systemName: "chevron.compact.down"), for: .normal)
        button.tintColor = .tertiaryLabel
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(handleSlideDownHandleButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var mainTrackDetailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var trackArtworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private lazy var progressContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var playbackProgressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        return slider
    }()
    
    private lazy var timeLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var currentTimeValueLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var durationValueLabel: UILabel = {
        let label = UILabel()
        label.text = "--:--"
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var titlesContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var trackTitleTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Track title"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var authorTitleTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Author"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .systemPink
        return label
    }()
    
    private lazy var playbackControlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var previousTrackButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        button.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private lazy var playPauseToggleButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 54, weight: .bold)
        button.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .label
        button.layer.cornerRadius = 28
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var nextTrackButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        button.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private lazy var volumeControlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var volumeMinIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "speaker.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    
    private lazy var volumeLevelSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
        return slider
    }()
    
    private lazy var volumeMaxIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "speaker.wave.3.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupUserInterface()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .systemBackground
        setupUserInterface()
        setupConstraints()
    }
    
    // MARK: - Setup
    
    private func setupUserInterface() {
        addSubview(mainTrackDetailStackView)
        
        mainTrackDetailStackView.addArrangedSubviews(
            slideDownHandleButton,
            trackArtworkImageView,
            progressContainerStackView,
            titlesContainerStackView,
            playbackControlsStackView,
            volumeControlsStackView
        )
        
        progressContainerStackView.addArrangedSubviews(
            playbackProgressSlider,
            timeLabelsStackView
        )
        
        timeLabelsStackView.addArrangedSubviews(
            currentTimeValueLabel,
            durationValueLabel
        )
        
        titlesContainerStackView.addArrangedSubviews(
            trackTitleTextLabel,
            authorTitleTextLabel
        )
        
        playbackControlsStackView.addArrangedSubviews(
            previousTrackButton,
            playPauseToggleButton,
            nextTrackButton
        )
        
        volumeControlsStackView.addArrangedSubviews(
            volumeMinIconImageView,
            volumeLevelSlider,
            volumeMaxIconImageView
        )
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        mainTrackDetailStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.equalTo(safeAreaLayoutGuide).offset(30)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(30)
            
            slideDownHandleButton.snp.makeConstraints { make in
                make.height.equalTo(44)
            }
            
            trackArtworkImageView.snp.makeConstraints { make in
                make.height.equalTo(trackArtworkImageView.snp.width)
            }
            
            previousTrackButton.snp.makeConstraints { make in
                make.width.height.equalTo(44)
            }
            playPauseToggleButton.snp.makeConstraints { make in
                make.width.height.equalTo(56)
            }
            nextTrackButton.snp.makeConstraints { make in
                make.width.height.equalTo(44)
            }
            
            volumeMinIconImageView.snp.makeConstraints { make in
                make.height.equalTo(17)
                make.width.equalTo(volumeMinIconImageView.snp.height)
            }
            volumeMaxIconImageView.snp.makeConstraints { make in
                make.height.equalTo(17)
                make.width.equalTo(volumeMaxIconImageView.snp.height)
            }
        }
        
        // MARK: - Public API
        
        func configureContent(trackTitle: String, authorTitle: String, artworkImage: UIImage?) {
            trackTitleTextLabel.text = trackTitle
            authorTitleTextLabel.text = authorTitle
            trackArtworkImageView.image = artworkImage
        }
        
        func updateTimeLabels(currentTimeText: String, durationText: String) {
            currentTimeValueLabel.text = currentTimeText
            durationValueLabel.text = durationText
        }
    }
    
    // MARK: - Action
    
    @objc private func handleSlideDownHandleButtonTap() {
        self.removeFromSuperview()
    }
}



