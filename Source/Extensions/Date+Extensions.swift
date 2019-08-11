//
//  Date+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension Date {

    private static var currentTimeZoneCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }()

    static let today = Date().beginningOfDay

    static var standard: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
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

    static var jsonFriendly: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        return formatter
    }

    static func easy(_ mmddyyyy: String) -> Date {
        return Date.standard.date(from: mmddyyyy) ?? Date()
    }

    var year: Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        return year
    }

    var day: Int {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self)
        return day
    }

    var month: String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        // Subtract one to keep December in range
        return calendar.monthSymbols[month - 1]
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
}

