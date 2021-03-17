//
//  ViewController.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Improved and maintaining by Ljuka
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import CalendarDateRangePicker

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var label: UILabel!

    var dateRangePickerViewController = CalendarDateRangePickerViewController(collectionViewLayout: UICollectionViewFlowLayout())

    var dateRangePicker: CalendarDateRangePickerViewController {
        let layout = UICollectionViewFlowLayout()
        if #available(iOS 10.0, *) {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        } else {
            // Fallback on earlier versions
        }
        return CalendarDateRangePickerViewController(collectionViewLayout: layout)
    }

    var startDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
    var endDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatePicker()
    }

    func configureDatePicker() {
        dateRangePickerViewController.delegate = self
        dateRangePickerViewController.minimumDate = Date()
        dateRangePickerViewController.maximumDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())

        dateRangePickerViewController.selectedColor = UIColor(hex: 0x008ad7)
        dateRangePickerViewController.todaySelectedColor = UIColor(hex: 0x008ad7)
        dateRangePickerViewController.cellHighlightedColor = UIColor(hex: 0xD1E7F5)
        dateRangePickerViewController.titleText = "Select Date Range"

        containerView.layer.masksToBounds = true

        addChild(dateRangePicker)
        containerView.addSubview(dateRangePickerViewController.view)
        dateRangePickerViewController.view.bindFrameToSuperviewBounds()
        dateRangePickerViewController.didMove(toParent: self)
    }
    
    @IBAction func didTapButton(_ sender: Any) {

    }
}

extension ViewController: CalendarDateRangePickerViewControllerDelegate {

    func didCancelPickingDateRange() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    func didPickDateRange(startDate: Date!, endDate: Date!) {
        self.startDate = startDate
        self.endDate = endDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        label.text = dateFormatter.string(from: startDate) + " to " + dateFormatter.string(from: endDate)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func didSelectStartDate(startDate: Date!) {

        if (dateRangePickerViewController.selectedEndDate != nil && dateRangePickerViewController.selectedStartDate != nil) {
            dateRangePickerViewController.selectedStartDate = nil
            dateRangePickerViewController.selectedEndDate = nil
            return
        }

        var gregorianUTC = Calendar.gregorian
        gregorianUTC.timeZone = TimeZone(identifier: "UTC")!
        let startDateInterval = startDate.startOfWeek(using: gregorianUTC)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"

        let calendar = Calendar.current
        let addOneDay = calendar.date(byAdding: .day, value: 1, to: startDateInterval)
        let addOneWeekToCurrentDate = calendar.date(byAdding: .day, value: 7, to: startDateInterval)

        dateRangePickerViewController.selectedEndDate = addOneWeekToCurrentDate
        dateRangePickerViewController.selectedStartDate = addOneDay
    }

    @objc func didSelectEndDate(endDate: Date!){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        print(dateFormatter.string(from: endDate))
    }
}

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}

extension Date {
    func startOfWeek(using calendar: Calendar = .gregorian) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red:   CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
            blue:  CGFloat((hex & 0x0000FF) >> 0)  / 255.0,
            alpha: alpha
        )
    }
}

extension UIView {
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            assertionFailure("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }

        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
    }
}
