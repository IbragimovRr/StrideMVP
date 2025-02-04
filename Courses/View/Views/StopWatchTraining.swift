//
//  StopWatchTraining.swift
//  Courses
//
//  Created by Руслан on 04.02.2025.
//

import Foundation

class Stopwatch {
    private var timer: Timer?
    private var startTime: Date?
    private var elapsedTime: TimeInterval = 0.0 {
        didSet {
            delegate?.timerDidUpdate(resultData: formatTime(elapsedTime))
        }
    }
    weak var delegate: TimerDelegate?
    var state: TimerState = .pause
    
    func start() {
        startTime = Date().addingTimeInterval(-elapsedTime)
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        state = .process
        delegate?.timerDidStart()
    }
    
    func pause() {
        if let start = startTime {
            elapsedTime = Date().timeIntervalSince(start)
        }
        timer?.invalidate()
        timer = nil
        state = .pause
        delegate?.timerDidPause()
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0.0
        state = .pause
    }
    
    @objc private func updateTimer() {
        guard let start = startTime else { return }
        let currentTime = Date().timeIntervalSince(start)
        elapsedTime = currentTime
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time - floor(time)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}


