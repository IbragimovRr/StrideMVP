//
//  TimerTraining.swift
//  Courses
//
//  Created by Руслан on 04.02.2025.
//

import Foundation

protocol TimerDelegate: AnyObject {
    func timerDidStart()
    func timerDidControlState(state: TimerState)
    func timerDidUpdate(resultData: String)
}

enum TimerState {
    case pause, process, end, reload, next
}


enum TimerMode {
    case stopwatch, timer
}

class TimerTraining {
    
    private var timer: Timer?
    
    private var initialSeconds: Int = 0
    private var seconds: Int = 0 {
        didSet {
            delegate?.timerDidUpdate(resultData: formatTime(seconds: seconds))
        }
    }
    var mode: TimerMode = .stopwatch
    var control: TimerState = .pause {
        didSet {
            delegate?.timerDidControlState(state: control)
        }
    }
    weak var delegate: TimerDelegate?
    
    func configure(seconds: Int, mode: TimerMode) {
        if mode == .timer {
            self.initialSeconds = seconds
            self.seconds = seconds
        }else {
            self.seconds = 0
        }
        control = .pause
        self.mode = mode
        stop()
    }
    
    //Если секунды уже были добавлены
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        control = .process
    }
    
    @objc func updateTimer() {
        switch mode {
        case .timer:
            if seconds > 0 {
                seconds -= 1
            } else {
                stop()
                control = .end
            }
        case .stopwatch:
            seconds += 1
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        control = .pause
    }
    
    func reload() {
        if mode == .timer {
            seconds = initialSeconds
        }else {
            seconds = 0
        }
        stop()
    }

    private func formatTime(seconds: Int) -> String {
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }


    
}
