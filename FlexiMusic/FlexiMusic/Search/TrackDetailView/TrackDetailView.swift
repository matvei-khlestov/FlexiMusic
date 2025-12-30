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

protocol TrackNavigationDelegate: AnyObject {
    func previousTrackViewModel() -> SearchViewModel.Cell?
    func nextTrackViewModel() -> SearchViewModel.Cell?
}

final class TrackDetailView: UIView {

    // MARK: - Delegates

    weak var delegate: TrackNavigationDelegate?
    weak var tabBarDelegate: TabBarControllerDelegate?

    // MARK: - Dependencies

    private let playerService: TrackPlayerServiceProtocol

    // MARK: - Player Observers

    private var boundaryObserverToken: Any?
    private var periodicObserverToken: Any?

    // MARK: - Constants

    private let fallbackDurationTime = CMTimeMake(value: 1, timescale: 1)

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

    let mainTrackDetailStackView: UIStackView = {
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
        stackView.distribution = .equalCentering
        stackView.spacing = 16
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

    let minimalTrackDetailsView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()

    private lazy var minimalTrackDetailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 16
        return stackView
    }()

    private lazy var minimalArtworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 0
        return imageView
    }()

    private lazy var minimalTrackTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private lazy var minimalPlayPauseButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        button.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(playPauseAction), for: .touchUpInside)
        return button
    }()

    private lazy var minimalNextTrackButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(nextTrack), for: .touchUpInside)
        return button
    }()

    private let minimalTrackDetailsTopSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.alpha = 0.6
        return view
    }()

    // MARK: - State

    func setMinimizedState() {
        minimalTrackDetailsView.alpha = 1
        minimalTrackDetailsStackView.alpha = 1
        mainTrackDetailStackView.alpha = 0
    }

    func setMaximizedState() {
        minimalTrackDetailsView.alpha = 0
        minimalTrackDetailsStackView.alpha = 0
        mainTrackDetailStackView.alpha = 1
    }

    // MARK: - Init

    override convenience init(frame: CGRect) {
        self.init(playerService: TrackPlayerService())
    }

    init(playerService: TrackPlayerServiceProtocol) {
        self.playerService = playerService
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        setupUserInterface()
        setupConstraints()
        setupGestureRecognizer()
        setMinimizedState()
    }

    required init?(coder: NSCoder) {
        self.playerService = TrackPlayerService()
        super.init(coder: coder)
        backgroundColor = .systemBackground
        setupUserInterface()
        setupConstraints()
        setupGestureRecognizer()
        setMinimizedState()
    }

    // MARK: - Setup

    func set(viewModel: SearchViewModel.Cell) {
        trackTitleLabel.text = viewModel.trackName
        authorTitleLabel.text = viewModel.artistName
        playTrack(previewUrl: viewModel.previewUrl)

        minimalTrackTitleLabel.text = viewModel.trackName

        monitorStartTime()
        observePlayerCurrentTime()

        setPlayPauseButtons(isPlaying: true)

        if let urlString = viewModel.iconUrl?.absoluteString {
            let string600 = urlString.replacingOccurrences(of: "100x100", with: "600x600")
            if let url = URL(string: string600) {
                trackArtworkImageView.kf.setImage(with: url)
                minimalArtworkImageView.kf.setImage(with: url)
            }
        }
    }

    private func setupUserInterface() {
        addSubviews(
            minimalTrackDetailsView,
            mainTrackDetailStackView
        )

        minimalTrackDetailsView.addSubviews(
            minimalTrackDetailsTopSeparatorView,
            minimalTrackDetailsStackView
        )

        minimalTrackDetailsStackView.addArrangedSubviews(
            minimalArtworkImageView,
            minimalTrackTitleLabel,
            minimalPlayPauseButton,
            minimalNextTrackButton
        )

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

    private func setupGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapMaximized)
        )
        minimalTrackDetailsView.addGestureRecognizer(tapGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanMinimized)
        )
        minimalTrackDetailsView.addGestureRecognizer(panGestureRecognizer)

        let dismissalPanGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleDismissalPan)
        )
        dismissalPanGestureRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(dismissalPanGestureRecognizer)
    }

    // MARK: - Constraints

    private func setupConstraints() {

        minimalTrackDetailsView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(64)
        }

        minimalTrackDetailsTopSeparatorView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
        }

        minimalTrackDetailsStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualTo(minimalTrackDetailsTopSeparatorView.snp.bottom).offset(6)
            make.bottom.lessThanOrEqualToSuperview().inset(6)
        }

        minimalArtworkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(48)
        }

        minimalPlayPauseButton.snp.makeConstraints { make in
            make.width.equalTo(44)
        }

        minimalNextTrackButton.snp.makeConstraints { make in
            make.width.equalTo(48)
        }

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
        removeBoundaryObserverIfNeeded()

        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        boundaryObserverToken = playerService.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeTrackImageView()
        }
    }

    private func observePlayerCurrentTime() {
        removePeriodicObserverIfNeeded()

        let interval = CMTimeMake(value: 1, timescale: 2)
        periodicObserverToken = playerService.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            currentTimeValueLabel.text = time.toDisplayString()

            let durationTime = playerService.currentItemDuration ?? fallbackDurationTime
            let currentDurationText = (durationTime - time).toDisplayString()
            durationValueLabel.text = "-\(currentDurationText)"
            updatePlaybackProgressSlider()
        }
    }

    private func updatePlaybackProgressSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(playerService.currentTime())
        let durationSeconds = CMTimeGetSeconds(playerService.currentItemDuration ?? fallbackDurationTime)
        let percentage = currentTimeSeconds / durationSeconds
        playbackProgressSlider.value = Float(percentage)
    }

    deinit {
        removeBoundaryObserverIfNeeded()
        removePeriodicObserverIfNeeded()
        printDeinit()
    }

    private func removeBoundaryObserverIfNeeded() {
        if let token = boundaryObserverToken {
            playerService.removeTimeObserver(token)
            boundaryObserverToken = nil
        }
    }

    private func removePeriodicObserverIfNeeded() {
        if let token = periodicObserverToken {
            playerService.removeTimeObserver(token)
            periodicObserverToken = nil
        }
    }

    // MARK: - Player

    private func playTrack(previewUrl: URL?) {
        #if DEBUG
        print("Пытаюсь включить трек по ссылке: \(previewUrl?.absoluteString ?? "Отсутствует")")
        #endif
        playerService.replaceAndPlay(previewUrl: previewUrl)
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
            },
            completion: nil
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
            },
            completion: nil
        )
    }

    // MARK: - Actions

    @objc private func handlePlaybackProgressSlider() {
        let percentage = playbackProgressSlider.value
        guard let duration = playerService.currentItemDuration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        playerService.seek(to: seekTime)
    }

    @objc private func handleVolumeLevelSlider() {
        playerService.playerVolume = volumeLevelSlider.value
    }

    @objc private func handleSlideDownHandleButtonTap() {
        tabBarDelegate?.minimizeTrackDetailController()
    }

    @objc private func playPauseAction() {
        if playerService.timeControlStatus == .paused {
            playerService.play()
            setPlayPauseButtons(isPlaying: true)
            enlargeTrackImageView()
        } else {
            playerService.pause()
            setPlayPauseButtons(isPlaying: false)
            reduceTrackImageView()
        }
    }

    @objc private func previousTrack() {
        let cellViewModel = delegate?.previousTrackViewModel()
        guard let cellInfo = cellViewModel else { return }
        set(viewModel: cellInfo)
    }

    @objc private func nextTrack() {
        let cellViewModel = delegate?.nextTrackViewModel()
        guard let cellInfo = cellViewModel else { return }
        set(viewModel: cellInfo)
    }

    // MARK: - Gestures

    @objc private func handleTapMaximized() {
        tabBarDelegate?.maximizeTrackDetailController(viewModel: nil)
    }

    @objc private func handlePanMinimized(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            handlePanChanged(gesture: gesture)
        case .ended:
            handlePanEnded(gesture: gesture)
        default:
            break
        }
    }

    private func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        transform = CGAffineTransform(translationX: 0, y: translation.y)

        let newAlpha = 1 + translation.y / 200
        minimalTrackDetailsView.alpha = newAlpha < 0 ? 0 : newAlpha
        mainTrackDetailStackView.alpha = -translation.y / 200
    }

    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        let velocity = gesture.velocity(in: superview)

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                self.transform = .identity
                if translation.y < -200 || velocity.y < -500 {
                    self.tabBarDelegate?.maximizeTrackDetailController(viewModel: nil)
                } else {
                    self.minimalTrackDetailsView.alpha = 1
                    self.mainTrackDetailStackView.alpha = 0
                }
            },
            completion: nil
        )
    }

    @objc private func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        let velocity = gesture.velocity(in: superview)

        switch gesture.state {
        case .changed:
            guard translation.y > 0 else { return }
            mainTrackDetailStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)

        case .ended:
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 1,
                options: .curveEaseInOut,
                animations: {
                    self.mainTrackDetailStackView.transform = .identity

                    if translation.y > 120 || velocity.y > 500 {
                        self.tabBarDelegate?.minimizeTrackDetailController()
                    }
                },
                completion: nil
            )

        case .cancelled, .failed:
            UIView.animate(withDuration: 0.25) {
                self.mainTrackDetailStackView.transform = .identity
            }

        default:
            break
        }
    }

    // MARK: - Private helpers

    private func setPlayPauseButtons(isPlaying: Bool) {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        let image = UIImage(systemName: imageName)
        playPauseToggleButton.setImage(image, for: .normal)
        minimalPlayPauseButton.setImage(image, for: .normal)
    }

    private func printDeinit() {
        #if DEBUG
        print("TrackDetailView memory being reclaimed...")
        #endif
    }
}



