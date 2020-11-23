//
//  Date+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension Date {

    static var currentTimeZoneCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }()

    static let today = Date().beginningOfDay

    static var nowInLocalFormat: String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, h:mm a"
        return formatter.string(from: now)
    }

    static var standard: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }

    static var monthAndDay: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }

    static var monthDayYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }

    static var weekdayMonthDayYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter
    }

    static func add(component: Calendar.Component,
                    amount: Int,
                    toDate: Date) -> Date? {

        let newDate = Calendar.current.date(byAdding: component,
                                            value: amount,
                                            to: toDate)
        return newDate
    }

    static func subtract(component: Calendar.Component,
                         amount: Int,
                         toDate: Date) -> Date? {
        let newDate = Calendar.current.date(byAdding: component,
                                            value: amount * -1,
                                            to: toDate)
        return newDate
    }

    func add(component: Calendar.Component, amount: Int) -> Date? {
        return Date.add(component: component, amount: amount, toDate: self)
    }

    func subtract(component: Calendar.Component, amount: Int) -> Date? {
        return Date.subtract(component: component, amount: amount, toDate: self)
    }

    static var jsonFriendly: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        return formatter
    }

    static var hourMinuteTimeOfDay: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h : mm a"
        return formatter
    }

    static var countDown: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH : mm : ss"
        return formatter
    }

    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }

    static func easy(_ mmddyyyy: String) -> Date {
        return Date.standard.date(from: mmddyyyy) ?? Date()
    }

    var year: Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        return year
    }

    var month: Int {
        let calendar = Calendar.current
        let day = calendar.component(.month, from: self)
        return day
    }

    var day: Int {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self)
        return day
    }

    var hour: Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        return hour
    }

    var minute: Int {
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: self)
        return minute
    }

    var second: Int {
        let calendar = Calendar.current
        let second = calendar.component(.second, from: self)
        return second
    }

    var beginningOfDay: Date {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Date.currentTimeZoneCalendar.date(from: dateComponents)!
    }

    var endOfDay: Date {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day,
                                                              .hour, .minute, .second],
                                                             from: self)
        dateComponents.hour = 23
        dateComponents.minute = 59
        dateComponents.second = 59
        return Date.currentTimeZoneCalendar.date(from: dateComponents)!
    }

    func isSameDay(as date: Date) -> Bool {
        return self.year == date.year
        && self.month == date.month
        && self.day == date.day
    }

    var ageInYears: Int {
        return Date().year - self.year
    }

    static func date(from components: DateComponents) -> Date? {
        let calendar = Calendar.current
        return calendar.date(from: components)
    }
}

extension Date: Diffable {
    func diffIdentifier() -> NSObjectProtocol {
        return String(self.hashValue) as NSObjectProtocol
    }
}

