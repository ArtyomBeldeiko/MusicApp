//
//  TrackDetailView.swift
//  MusicApp
//
//  Created by Artyom Beldeiko on 17.03.22.
//

import UIKit
import SDWebImage
import AVKit

protocol TrackDetailViewProtocol {
    
    func moveForward() -> SearchViewModel.Cell?
    func moveBackward() -> SearchViewModel.Cell?
    
}

class TrackDetailView: UIView {
    
    @IBOutlet weak var maximizedStackView: UIStackView!
    @IBOutlet weak var miniplayerView: UIView!
    @IBOutlet weak var miniPlayerViewSeparator: UIView!
    @IBOutlet weak var miniPlayerImageView: UIImageView!
    @IBOutlet weak var miniTrackTitleLabel: UILabel!
    @IBOutlet weak var miniPlayerPlayStopButton: UIButton!
    @IBOutlet weak var miniPlayerNextTrackButton: UIButton!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    var delegate: TrackDetailViewProtocol?
    weak var mainTabBarDelegate: MainTabBarControllerDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let scale: CGFloat = 0.8
        
        trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        trackImageView.layer.cornerRadius = 5
        
        setupGestures()
        
    }
    
    //    MARK: - Setup
    
    func set(viewModel: SearchViewModel.Cell) {
        
        trackTitleLabel.text = viewModel.artistName
        miniTrackTitleLabel.text = viewModel.trackName
        artistLabel.text = viewModel.trackName
        playTrack(previewUrl: viewModel.previewUrl!)
        monitorTime()
        observeCurrentTime()
        playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600")
        guard let url = URL(string: string600 ?? "") else { return }
        miniPlayerImageView.sd_setImage(with: url, completed: nil)
        trackImageView.sd_setImage(with: url, completed: nil)
        
    }
    
    private func setupGestures() {
        miniplayerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMaximizedView)))
        miniplayerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanDismiss)))
    }
    
    //    MARK: - Gestures Setup
    
    @objc private func tapMaximizedView() {
        self.mainTabBarDelegate?.maximizeTrackDetailController(viewModel: nil)
        
    }
    
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            print ("The pan has begun")
        case .changed:
            handlePanGestureChanged(gesture: gesture)
        case .ended:
            handlePanEnded(gesture: gesture)
        @unknown default:
            print ("Unknown default case")
        }
    }
    
    private func handlePanGestureChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        let newAlpha = translation.y / 200
        self.miniplayerView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.maximizedStackView.alpha = -translation.y / 200
        
    }
    
    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut) {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                self.mainTabBarDelegate?.maximizeTrackDetailController(viewModel: nil)
            } else {
                self.miniplayerView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        } completion: { completionResult in
            print(completionResult)
        }
        
    }
    
    @objc private func handlePanDismiss(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self.superview)
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        case .ended:
            let translation = gesture.translation(in: self.superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
                self.maximizedStackView.transform = .identity
                if translation.y > 50 {
                    self.mainTabBarDelegate?.minimizeTrackDetailController()
                }
            } completion: { completionResult in
                print(completionResult)
            }
            
        @unknown default:
            print("Unknown default case")
        }
        
    }
    
    private func playTrack(previewUrl: String) {
        
        guard let url = URL(string: previewUrl) else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
    }
    
    private func monitorTime() {
        
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeImageView()
        }
        
    }
    
    private func observeCurrentTime() {
        
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self?.durationLabel.text = "-\(currentDurationText)"
            self?.updateCurrentTimeSlider()
        }
        
    }
    
    private func updateCurrentTimeSlider() {
        
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    
    //    MARK: - Animations
    
    private func enlargeImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) {
            self.trackImageView.transform = .identity
        } completion: { result in
            print(result)
        }
        
    }
    
    private func reduceImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) {
            let scale: CGFloat = 0.8
            self.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { result in
            print(result)
        }
    }
    
    //    MARK: - IBActions
    
    @IBAction func dragDownTapped(_ sender: Any) {
        
        self.mainTabBarDelegate?.minimizeTrackDetailController()
        
    }
    
    @IBAction func handleCurrentTimeSlider(_ sender: Any) {
        
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
        
    }
    
    @IBAction func previousTrackButtonTapped(_ sender: Any) {
        
        let cellViewModel = delegate?.moveBackward()
        guard let cellData = cellViewModel else { return }
        self.set(viewModel: cellData)
        
    }
    
    @IBAction func playPauseButtonTapped(_ sender: Any) {
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            miniPlayerPlayStopButton.setImage(UIImage(named: "pause"), for: .normal)
            enlargeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            miniPlayerPlayStopButton.setImage(UIImage(named: "play"), for: .normal)
            reduceImageView()
        }
    }
    
    @IBAction func nextTrackButtonTapped(_ sender: Any) {
        
        let cellViewModel = delegate?.moveForward()
        guard let cellData = cellViewModel else { return }
        self.set(viewModel: cellData)
        
    }
    
    @IBAction func handleVolumeSlider(_ sender: Any) {
        
        player.volume = volumeSlider.value
        
    }
    
}
