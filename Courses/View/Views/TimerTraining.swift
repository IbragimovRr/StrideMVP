//
//  TimerTraining.swift
//  Courses
//
//  Created by Руслан on 04.02.2025.
//

import Foundation

protocol TimerDelegate: AnyObject {
    func timerDidStart()
    func timerDidPause()
    func timerDidEnd()
    func timerDidUpdate(resultData: String)
}

enum ControlsTimer {
    case pause, process, end, reload, next
}

class TimerTraining {
    
    private var timer: Timer?
    
    private var initialSeconds: Int = 0
    private var seconds: Int = 0 {
        didSet {
            delegate?.timerDidUpdate(resultData: formatTime(seconds: seconds))
        }
    }
    var control: ControlsTimer = .pause
    weak var delegate: TimerDelegate?
    
    func initial(seconds: Int) {
        self.initialSeconds = seconds
        self.seconds = seconds
        control = .pause
    }
    
    func start(seconds: Int) {
        initialSeconds = seconds
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        control = .process
        delegate?.timerDidStart()
    }
    
    //Если секунды уже были добавлены
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        control = .process
        delegate?.timerDidStart()
    }
    
    @objc func updateTimer() {
        if seconds > 0 {
            seconds -= 1
        } else {
            stop()
            delegate?.timerDidEnd()
            control = .end
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        delegate?.timerDidPause()
        control = .pause
    }
    
    func reload() {
        seconds = initialSeconds
        stop()
    }

    private func formatTime(seconds: Int) -> String {
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }


    
}
