//
//  CalendarDateRangePickerViewController.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Improved and maintaining by Ljuka
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

@objc public protocol CalendarDateRangePickerViewControllerDelegate: class {
    func didCancelPickingDateRange()
    func didPickDateRange(startDate: Date!, endDate: Date!)
    func didSelectStartDate(startDate: Date!)
    func didSelectEndDate(endDate: Date!)
}

@objcMembers public class CalendarDateRangePickerViewController: UICollectionViewController {
    
    let cellReuseIdentifier = "CalendarDateRangePickerCell"
    let headerReuseIdentifier = "CalendarDateRangePickerHeaderView"
    
    weak public var delegate: CalendarDateRangePickerViewControllerDelegate!
    
    let itemsPerRow = 7
    let itemHeight: CGFloat = 40
    let collectionViewInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
    
    public var minimumDate: Date!
    public var maximumDate: Date!
    
    public var selectedStartDate: Date?
    public var selectedEndDate: Date?
    var selectedStartCell: IndexPath?
    var selectedEndCell: IndexPath?
    
    public var disabledDates: [Date]?
    
    public var cellHighlightedColor = UIColor(white: 0.9, alpha: 1.0)
    public static let defaultCellFontSize:CGFloat = 15.0
    public static let defaultHeaderFontSize:CGFloat = 17.0
    public var cellFont:UIFont = UIFont(name: "HelveticaNeue", size: CalendarDateRangePickerViewController.defaultCellFontSize)!
    public var headerFont:UIFont = UIFont(name: "HelveticaNeue-Light", size: CalendarDateRangePickerViewController.defaultHeaderFontSize)!
    
    
    public var selectedColor = UIColor(red: 66/255.0, green: 150/255.0, blue: 240/255.0, alpha: 1.0)
    public var selectedLabelColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    public var highlightedLabelColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    public var titleText = "Select Dates"
    public var cancelText = "Cancel"
    public var doneText = "Done"
    public var selectionMode: SelectionMode = .range
    
    @objc public enum SelectionMode: Int {
        case range = 0
        case single = 1
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.titleText

        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = UIColor.white

        collectionView?.register(CalendarDateRangePickerCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView?.register(CalendarDateRangePickerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView?.contentInset = collectionViewInsets

        if minimumDate == nil {
            minimumDate = Date()
        }
        if maximumDate == nil {
            maximumDate = Calendar.current.date(byAdding: .year, value: 3, to: minimumDate)
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: cancelText, style: .plain, target: self, action: #selector(CalendarDateRangePickerViewController.didTapCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: doneText, style: .done, target: self, action: #selector(CalendarDateRangePickerViewController.didTapDone))
        self.navigationItem.rightBarButtonItem?.isEnabled = selectedStartDate != nil && selectedEndDate != nil
    }

    @objc func didTapCancel() {
        delegate.didCancelPickingDateRange()
    }

    @objc func didTapDone() {
        if selectedStartDate == nil || selectedEndDate == nil {
            return
        }
        delegate.didPickDateRange(startDate: selectedStartDate!, endDate: selectedEndDate!)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedStartDate != nil{
            self.scrollToSelection()
        }
    }
}

extension CalendarDateRangePickerViewController {

    // UICollectionViewDataSource

    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        let difference = Calendar.current.dateComponents([.month], from: minimumDate, to: maximumDate)
        return difference.month! + 1
    }

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let firstDateForSection = getFirstDateForSection(section: section)
        let weekdayRowItems = 7
        let blankItems = getWeekday(date: firstDateForSection) - 1
        let daysInMonth = getNumberOfDaysInMonth(date: firstDateForSection)
        return weekdayRowItems + blankItems + daysInMonth
    }

    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CalendarDateRangePickerCell

        cell.highlightedColor = self.cellHighlightedColor
        cell.selectedColor = self.selectedColor
        cell.selectedLabelColor = self.selectedLabelColor
        cell.highlightedLabelColor = self.highlightedLabelColor
        cell.font = self.cellFont
        cell.reset()
        let blankItems = getWeekday(date: getFirstDateForSection(section: indexPath.section)) - 1
        if indexPath.item < 7 {
            cell.label.text = getWeekdayLabel(weekday: indexPath.item + 1)
        } else if indexPath.item < 7 + blankItems {
            cell.label.text = ""
        } else {
            let dayOfMonth = indexPath.item - (7 + blankItems) + 1
            let date = getDate(dayOfMonth: dayOfMonth, section: indexPath.section)
            cell.date = date
            cell.label.text = "\(dayOfMonth)"

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let datePreFormatted = dateFormatter.string(from: date)
            let dateFormatted = dateFormatter.date(from: datePreFormatted)

            if disabledDates != nil{
                if (disabledDates?.contains(cell.date!))!{
                    cell.disable()
                }
            }
            if isBefore(dateA: date, dateB: minimumDate) {
                cell.disable()
            }

            if selectedStartDate != nil && selectedEndDate != nil && isBefore(dateA: selectedStartDate!, dateB: date) && isBefore(dateA: date, dateB: selectedEndDate!) {
                // Cell falls within selected range
                if dayOfMonth == 1 {
                    if #available(iOS 9.0, *) {
                        if UIView.appearance().semanticContentAttribute == .forceRightToLeft {
                            cell.highlightLeft()
                        }
                        else{
                            cell.highlightRight()
                        }
                    } else {
                        // Use the previous technique
                        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                            cell.highlightLeft()
                        }
                        else{
                            cell.highlightRight()
                        }
                    }
                } else if dayOfMonth == getNumberOfDaysInMonth(date: date) {
                    if #available(iOS 9.0, *) {
                        if UIView.appearance().semanticContentAttribute == .forceRightToLeft{
                            cell.highlightRight()
                        }
                        else{
                            cell.highlightLeft()
                        }
                    } else {
                        // Use the previous technique
                        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                            cell.highlightRight()
                        }
                        else{
                            cell.highlightLeft()
                        }
                    }
                } else {
                    cell.highlight()
                }
            } else if selectedStartDate != nil && areSameDay(dateA: date, dateB: selectedStartDate!) {
                // Cell is selected start date
                cell.select()
                if selectedEndDate != nil {
                    if #available(iOS 9.0, *) {
                        if UIView.appearance().semanticContentAttribute == .forceRightToLeft{
                            cell.highlightLeft()
                        }
                        else{
                            cell.highlightRight()
                        }
                    } else {
                        // Use the previous technique
                        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                            cell.highlightLeft()
                        }
                        else{
                            cell.highlightRight()
                        }
                    }
                }
            } else if selectedEndDate != nil && areSameDay(dateA: date, dateB: selectedEndDate!) {
                cell.select()
                if #available(iOS 9.0, *) {
                    if UIView.appearance().semanticContentAttribute == .forceRightToLeft{
                        cell.highlightRight()
                    }
                    else{
                        cell.highlightLeft()
                    }
                } else {
                    // Use the previous technique
                    if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                        cell.highlightRight()
                    }
                    else{
                        cell.highlightLeft()
                    }
                }
            }
        }
        return cell
    }

    override public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! CalendarDateRangePickerHeaderView
            headerView.label.text = getMonthLabel(date: getFirstDateForSection(section: indexPath.section))
            headerView.font = headerFont
            return headerView
        default:
            fatalError("Unexpected element kind")
        }
    }

}

extension CalendarDateRangePickerViewController : UICollectionViewDelegateFlowLayout {

    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarDateRangePickerCell
        if cell.date == nil {
            return
        }
        if isBefore(dateA: cell.date!, dateB: minimumDate){
            return
        }

        if disabledDates != nil{
            if (disabledDates?.contains(cell.date!))!{
                return
            }
        }
        
        if selectedStartDate == nil || selectionMode == .single {
            selectedStartDate = cell.date
            selectedStartCell = indexPath
            delegate.didSelectStartDate(startDate: selectedStartDate)
        } else if selectedEndDate == nil {
            if isBefore(dateA: selectedStartDate!, dateB: cell.date!) && !isBetween(selectedStartCell!, and: indexPath){
                selectedEndDate = cell.date
                delegate.didSelectEndDate(endDate: selectedEndDate)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                // If a cell before the currently selected start date is selected then just set it as the new start date
                selectedStartDate = cell.date
                selectedStartCell = indexPath
                delegate.didSelectStartDate(startDate: selectedStartDate)
            }
        } else {
            selectedStartDate = cell.date
            selectedStartCell = indexPath
            delegate.didSelectStartDate(startDate: selectedStartDate)
            selectedEndDate = nil
        }
        collectionView.reloadData()
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = collectionViewInsets.left + collectionViewInsets.right
        let availableWidth = view.frame.width - padding
        let itemWidth = availableWidth / CGFloat(itemsPerRow)
        return CGSize(width: itemWidth, height: itemHeight)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 50)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}

extension CalendarDateRangePickerViewController {

    // Helper functions
    
    private func scrollToSelection(){
        if let uCollectionView = collectionView{
            let sections = uCollectionView.numberOfSections
            
            for section in 0..<sections {
                
                let items = uCollectionView.numberOfItems(inSection: section)
                for item in 0..<items {
                    let indexPath = IndexPath(item: item, section: section)
                    
                    if isDayItem(at: indexPath) && isDaySelected(at: indexPath) {
                        self.selectedStartCell = indexPath
                        collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredVertically, animated: false)
                        return
                    }
                }
            }
        }
    }
    
    func isCellBlank(at indexPath: IndexPath) -> Bool {
        let blankItems = getWeekday(date: getFirstDateForSection(section: indexPath.section)) - 1
        if indexPath.item >= 7 && indexPath.item < 7 + blankItems {
            return true
        }
        
        return false
    }
    
    func isWeekDayLabel(at indexPath: IndexPath) -> Bool {
        if indexPath.item < 7{
            return true
        }
        
        return false
    }
    
    func isDayItem(at indexPath: IndexPath) -> Bool {
        if !isCellBlank(at: indexPath) && !isWeekDayLabel(at: indexPath){
            return true
        }
        
        return false
    }
    
    func isDaySelected(at indexPath: IndexPath) -> Bool {
        let blankItems = getWeekday(date: getFirstDateForSection(section: indexPath.section)) - 1
        let dayOfMonth = indexPath.item - (7 + blankItems) + 1
        let date = getDate(dayOfMonth: dayOfMonth, section: indexPath.section)
        
        if selectedStartDate != nil && selectedEndDate != nil && isBefore(dateA: selectedStartDate!, dateB: date) && isBefore(dateA: date, dateB: selectedEndDate!) {
            return true
        } else if selectedStartDate != nil && areSameDay(dateA: date, dateB: selectedStartDate!) {
            return true
        } else if selectedEndDate != nil && areSameDay(dateA: date, dateB: selectedEndDate!) {
            return true
        }
        
        return false
    }
    
    @objc func getFirstDate() -> Date {
        var components = Calendar.current.dateComponents([.month, .year], from: minimumDate)
        components.day = 1
        return Calendar.current.date(from: components)!
    }

    @objc func getFirstDateForSection(section: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: section, to: getFirstDate())!
    }

    @objc func getMonthLabel(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }

    @objc func getWeekdayLabel(weekday: Int) -> String {
        var components = DateComponents()
        components.calendar = Calendar.current
        components.weekday = weekday
        let date = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: Calendar.MatchingPolicy.strict)
        if date == nil {
            return "E"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEE"
        return dateFormatter.string(from: date!)
    }

    @objc func getWeekday(date: Date) -> Int {
        return Calendar.current.dateComponents([.weekday], from: date).weekday!
    }

    @objc func getNumberOfDaysInMonth(date: Date) -> Int {
        return Calendar.current.range(of: .day, in: .month, for: date)!.count
    }

    @objc func getDate(dayOfMonth: Int, section: Int) -> Date {
        var components = Calendar.current.dateComponents([.month, .year], from: getFirstDateForSection(section: section))
        components.day = dayOfMonth
        return Calendar.current.date(from: components)!
    }

    @objc func areSameDay(dateA: Date, dateB: Date) -> Bool {
        return Calendar.current.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedSame
    }

    @objc func isBefore(dateA: Date, dateB: Date) -> Bool {
        return Calendar.current.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedAscending
    }

    @objc func isBetween(_ startDateCellIndex: IndexPath, and endDateCellIndex: IndexPath) -> Bool {

        if disabledDates == nil{
            return false
        }

        var index = startDateCellIndex.row
        var section = startDateCellIndex.section
        var currentIndexPath: IndexPath
        var cell: CalendarDateRangePickerCell?

        while !(index == endDateCellIndex.row && section == endDateCellIndex.section){
            currentIndexPath = IndexPath(row: index, section: section)
            cell = collectionView?.cellForItem(at: currentIndexPath) as? CalendarDateRangePickerCell
            if cell?.date == nil{
                section = section + 1
                let blankItems = getWeekday(date: getFirstDateForSection(section: section)) - 1
                index = 7 + blankItems
                currentIndexPath = IndexPath(row: index, section: section)
                cell = collectionView?.cellForItem(at: currentIndexPath) as? CalendarDateRangePickerCell
            }

            if cell != nil && (disabledDates?.contains((cell!.date)!))! {
                return true
            }
            index = index + 1
        }

        return false
    }

}
