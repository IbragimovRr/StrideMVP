//
//  PickerTimeViewController.swift
//  Courses
//
//  Created by Руслан on 26.01.2025.
//

import UIKit

class PickerTimeViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate: AddTimeDelegate!
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTime()
    }
    
    private func getTime() {
        let selectedTime = datePicker.date

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: selectedTime)

        let timeComponents = timeString.split(separator: ":")
        let minutes = timeComponents[0]
        let seconds = timeComponents[1]
        delegate.time(minutes: String(minutes), seconds: String(seconds), index: index)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        getTime()
    }
    
    @IBAction func done(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: false)
    }
}
