//
//  TrackDetailView.swift
//  FlexiMusic
//
//  Created by Matvei Khlestov on 03.08.2025.
//

import UIKit
import SnapKit
import Kingfisher
import AVFoundation

protocol TrackMovingDelegate: AnyObject {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell?
    func moveForwardForPreviousTrack() -> SearchViewModel.Cell?
}

final class TrackDetailView: UIView {
    
    // MARK: - Delegates
    
    weak var delegate: TrackMovingDelegate?
    weak var tabBarDelegate: TabBarControllerDelegate?
    
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
        let scale: CGFloat = 0.8
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 5
        imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
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
        slider.addTarget(self, action: #selector(handlePlaybackProgressSlider), for: .valueChanged)
        return slider
    }()
    
    private lazy var volumeLevelSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
        slider.addTarget(self, action: #selector(handleVolumeLevelSlider), for: .valueChanged)
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
    
    private lazy var trackTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Track title"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var authorTitleLabel: UILabel = {
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
        button.addTarget(self, action: #selector(previousTrack), for: .touchUpInside)
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
        button.addTarget(self, action: #selector(playPauseAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextTrackButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        button.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(nextTrack), for: .touchUpInside)
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
    
    private lazy var volumeMaxIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "speaker.wave.3.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    
    private let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
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
    
    func set(viewModel: SearchViewModel.Cell) {
        trackTitleLabel.text = viewModel.trackName
        authorTitleLabel.text = viewModel.artistName
        playTrack(previewUrl: viewModel.previewUrl)
        
        monitorStartTime()
        observeOlayerCurrentTime()
        
        if let urlString = viewModel.iconUrl?.absoluteString {
            let string600 = urlString.replacingOccurrences(of: "100x100", with: "600x600")
            if let url = URL(string: string600) {
                trackArtworkImageView.kf.setImage(with: url)
            }
        }
    }
    
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
            trackTitleLabel,
            authorTitleLabel
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
    }
    
    // MARK: - Time setup
    
    private func monitorStartTime() {
        
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeTrackImageView()
        }
    }
    
    private func observeOlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            guard let self else { return }
            self.currentTimeValueLabel.text = time.toDisplayString()
            
            let durationTime = self.player.currentItem?.duration
            let currentDurationText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self.durationValueLabel.text = "-\(currentDurationText)"
            self.updatePlaybackProgressSlider()
        }
    }
    
    private func updatePlaybackProgressSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.playbackProgressSlider.value = Float(percentage)
    }
    
    deinit {
        print("TrackDetailView memory being reclaimed...")
    }
    
    // MARK: - Player
    
    private func playTrack(previewUrl: URL?) {
        print("Пытаюсь включить трек по ссылке: \(previewUrl?.absoluteString ?? "Отсутствует")")
        
        guard let url = previewUrl else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    // MARK: - Animations
    
    private func enlargeTrackImageView() {
        UIView.animate(
            withDuration: 1,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: .curveEaseInOut,
            animations: {
                self.trackArtworkImageView.transform = .identity
            }, completion: nil
        )
    }
    
    private func reduceTrackImageView() {
        UIView.animate(
            withDuration: 1,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: .curveEaseInOut,
            animations: {
                let scale: CGFloat = 0.8
                self.trackArtworkImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }, completion: nil
        )
    }
    
    // MARK: - Action
    
    @objc private func handlePlaybackProgressSlider() {
        let percentage = playbackProgressSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeUnSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeUnSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @objc private func handleVolumeLevelSlider() {
        player.volume = volumeLevelSlider.value
    }
    
    @objc private func handleSlideDownHandleButtonTap() {
        self.tabBarDelegate?.minimizeTrackDetailController()
    }
    
    @objc private func playPauseAction() {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseToggleButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            enlargeTrackImageView()
        } else {
            player.pause()
            playPauseToggleButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            reduceTrackImageView()
        }
    }
    
    @objc private func previousTrack() {
        let cellViewModel = delegate?.moveBackForPreviousTrack()
        guard let cellInfo = cellViewModel else { return }
        self.set(viewModel: cellInfo)
    }
    
    @objc private func nextTrack() {
        let cellViewModel = delegate?.moveForwardForPreviousTrack()
        guard let cellInfo = cellViewModel else { return }
        self.set(viewModel: cellInfo)
    }
}



