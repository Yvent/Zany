//
//  Zany.swift
//  Zany
//
//  Created by 周逸文 on 2018/3/18.
//  Copyright © 2018年 YV. All rights reserved.
//

import Foundation
import AVFoundation

open class Zany: Equatable {
    
    
    
    /// state of the player
    ///
    /// - paused:  player is paused
    /// - running: player is running
    /// - finished: player is finished
    public enum State: Equatable, CustomStringConvertible {
        case paused
        case running
        case finished
        
        
        /// if player is paused ,return true
        public var isPaused: Bool {
            guard case .paused = self else { return false }
            return true
        }
        
        /// if player is running ,return true
        public var isRunning: Bool {
            guard case .running = self else { return false }
            return true
        }
        
        /// if player is finished ,return true
        public var isFinished: Bool {
            guard case .finished = self else { return false }
            return true
        }
        
        /// state description
        public var description: String {
            switch self {
            case .paused:    return "paused"
            case .finished:    return "finished"
            case .running:    return "running"
            }
        }
        
    }
    
//    /// mode of the player.
//    ///
//    /// - order: order play of player.
//    /// - single: single play of player.
//    /// - random: random play of player.
//    public enum Mode {
//        case order
//        case single
//        case random
//    }
    
    
    /// the player
    private var player: AVPlayer? = nil
    
    /// callback called to intercept playerItem's change of the player
    public var onPlayerItemAddObserver: ((_ zany: Zany, _ item: AVPlayerItem) -> (Void))? = nil
    
    /// callback called to intercept playerItem's change of the player
    public var onPlayerItemRemoveObserver: ((_ zany: Zany, _ item: AVPlayerItem) -> (Void))? = nil
    
    /// item of the player
    private var playerItem: AVPlayerItem? {
        willSet {
            if self.playerItem == newValue{ return }
            if let item = self.playerItem {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
                
                self.onPlayerItemRemoveObserver?(self,item)
            }
            self.playerItem = newValue
            if let item = newValue{
                NotificationCenter.default.addObserver(self, selector: #selector(zanyPlayDidEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
                self.onPlayerItemAddObserver?(self,item)
            }
        }
    }
    
    /// current state of the player
    public private(set) var state: State = .paused {
        didSet {
            self.onStateChanged?(self,state)
        }
    }
    
    /// callback called to intercept state's change of the player
    public var onStateChanged: ((_ zany: Zany, _ state: State) -> (Void))? = nil
    
    /// list of the observer of the player
    private var observers = [ObserverToken : Observer]()
    /// next token of the player
    private var nextObserverID: UInt64 = 0
    
    /// progress Observer
    public typealias Observer = ((Zany,Float) -> (Void))
    
    public typealias ItemObserver = ((_ zany: Zany, _ item: AVPlayerItem) -> (Void))
    /// Token assigned to the observer
    public typealias ObserverToken = UInt64
    
    private var timeObserver: Any?
    /// url of the player
    private var url: URL
    ///  play mode of the player.
//    public private(set) var mode: Mode
    /// Unique identifier
    public let id: UUID = UUID()
    
    public typealias Progress = ((Zany) -> (Void))
    
    /// initialize a new player.
    ///
    /// - Parameters:
    ///   - url: url of the player
    ///   - mode: mode of the player
    ///   - queue: queue in which the player should be executed; if `nil` a new queue is created automatically.
    ///   - observer: observer
    public init(url: URL,
                observer: Observer? = nil,
                ItemAddObserver: ItemObserver? = nil,
                ItemRemoveObserver: ItemObserver? = nil) {
        
        self.url = url
//        self.mode = mode
        self.onPlayerItemAddObserver = ItemAddObserver
        self.onPlayerItemRemoveObserver = ItemRemoveObserver
        self.player = configurePlayer()
        guard let newobserver = observer else { return }
        self.observe(newobserver)
        
    }
    
    
    /// configure a new playeritem
    ///
    /// - returns: playeritem
    private func configureItem() -> AVPlayerItem {
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        return playerItem
    }
    
    /// configure a new player
    ///
    /// - returns: player
    private func configurePlayer() -> AVPlayer {
        self.playerItem = configureItem()
        let player = AVPlayer(playerItem: self.playerItem)
        let interval = CMTime(seconds: 0.5,preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] (time) in
            
            if let totalTimeDuration = self?.playerItem?.duration {
                let currentTime: Float = Float(CMTimeGetSeconds(time))
                let totalTime: Float = Float(CMTimeGetSeconds(totalTimeDuration))
                let value = currentTime/totalTime
                guard let unwrapped = self  else{ return }
                unwrapped.observers.values.forEach {
                    $0(unwrapped, value)
                }
            }
        }
        
        return player
    }
    
    
    /// add new a listener to the player.
    ///
    /// - Parameter callback: callback to call for fire events.
    /// - returns: token used to remove the handler
    @discardableResult
    public func observe(_ observer: @escaping Observer) -> ObserverToken {
        
        var (new,overflow) = self.nextObserverID.addingReportingOverflow(1)
        if overflow {
            self.nextObserverID = 0
            new = 0
        }
        self.nextObserverID = new
        self.observers[new] = observer
        return new
    }
    
    
    /// reset the state of the player, optionally changing the player url.
    ///
    /// - Parameters:
    ///   - url: new player url.
    ///   - restart: `true` to automatically restart the player, `false` to keep it stopped after configuration.
    public func reset(_ url: URL?, restart: Bool = true) {
        if self.state.isRunning {
            self.setPause()
        }
        
        // create a new instance of player configured
        if let newurl = url { self.url = newurl } // update url
        self.player = configurePlayer()
        
        self.state = .paused
        
        if restart {
            self.player?.play()
            self.state = .running
        }
    }
    
    /// start player. If player is already running it does nothing.
    @discardableResult
    public func play() -> Bool {
        // if player is running, it do nothing
        guard self.state.isRunning == false else {
            return false
        }
        // only player is paused, player to play
        guard self.state.isFinished == true else {
            self.state = .running
            self.player?.play()
            return true
        }
        
        // only player is finished, it reset
        self.reset(nil, restart: true)
        return true
    }
    
    /// pause a running player. If player is paused it does nothing.
    @discardableResult
    public func pause() -> Bool {
        return self.setPause()
    }
    
    /// pause a running player optionally changing the state.
    @discardableResult
    private func setPause(to state: State = .paused) -> Bool {
        guard self.state.isRunning || self.state.isFinished else {
            return false
        }
        
        self.player?.pause()
        self.state = state
        
        return true
    }
    /// playerItem play end
    @objc func zanyPlayDidEnd(_ noti: NSNotification)  {
        self.setFinished()
    }
    
    /// a player is finished.
    @discardableResult
    public func testFinished() -> Bool {
        return self.setFinished()
    }
    
    @discardableResult
    private func setFinished() -> Bool {
        self.state = .finished
        return true
    }
    
    /// remove an observer of the player. by id
    public func remove(observer id: ObserverToken) {
        self.observers.removeValue(forKey: id)
    }
    
    /// remove the timeObserver
    private func removeTimeObserver() {
        guard let observer = self.timeObserver else {
            return
        }
        self.player?.removeTimeObserver(observer)
    }
    
    /// remove all
    public func removeAll() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        self.observers.removeAll()
        self.pause()
        self.removeTimeObserver()
        if let item = self.playerItem {
            self.onPlayerItemRemoveObserver?(self,item)
        }
        self.player = nil
        self.playerItem = nil
        self.timeObserver = nil
        
    }
    
    public static func ==(lhs: Zany, rhs: Zany) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    deinit {
        self.removeAll()
    }
}

