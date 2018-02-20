//
//  engine.swift
//  schedyouler
//
//  Created by divine on 2/19/18.
//  Copyright © 2018 divine ikenna. All rights reserved.
//

import Foundation
import EventKit

struct Constants {
    static let timeDelta : Int = 15
    static let daysInWeek : Int = 7
    static let hoursInDay : Int = 24
    static let minutesInHour : Int = 60
    static let secondsInMinute : Int = 60
    static var secondsInWeek : Int {
        return daysInWeek * hoursInDay * minutesInHour * secondsInMinute
    }
    static var dayLength : Int {
        return (hoursInDay * secondsInMinute) / timeDelta
    }
    static var timelineLength : Int {
        return dayLength * daysInWeek
    }
}

struct Availability {
    static let AVAILABLE : Int = 0
    static let UNAVAILABLE : Int = 1
}

private let TERMINATOR : Int = Availability.UNAVAILABLE

/* Create tagArray and timeline arrays */
struct TagArray {
    //var startDayOfWeek : Int
    //var endDayOfWeek : Int
    var arr = Array(repeating: Array(repeating: Availability.AVAILABLE, count: Constants.dayLength), count: Constants.daysInWeek)
}


struct ScheduledTimeGenerator: Sequence, IteratorProtocol {
    private let eventStore = EKEventStore()
    private var tagArray : TagArray
    private var dateOne : Date//= Date(timeIntervalSince1970: 1)
    private var dateTwo : Date// = Date(timeIntervalSince1970: 19700000)
    private var eventDuration : Int
    
    private var timeline : [Int] = Array(repeating: Availability.AVAILABLE, count: Constants.timelineLength + TERMINATOR) //timeline[-1] is always a 1-terminator!
    
    /* Get weeks between two dates */
    private var weeksInBetween : Int {
        didSet {
            weeksList = Array(0..<weeksInBetween)//.shuffled()
        }
    }
    
    /* Choose random n to investigate */
    private var weeksList : [Int]!
    private var weeks_ptr : Int = 0  {
        didSet {
            clearTimeline()
        }
    }
    private var openingsList : [ClosedRange<Int>]!
    private var openingsIndices : [Int]!
    private var openings_ptr : Int = 0 {
        didSet {
            if openings_ptr >= openingsIndices.count {
                openingsIndices = nil
                weeks_ptr += 1
            }
        }
    }
    
    private var slotsList : [Int]!
    private var slots_ptr : Int = 0 {
        didSet {
            if slots_ptr >= slotsList.count {
                slotsList = nil
                openings_ptr += 1
            }
        }
    }
    
    init(between dateOne: Date, and dateTwo: Date, for eventDuration: Int, withRestrictions tagArray: TagArray) {
        self.timeline[self.timeline.count - 1] = TERMINATOR
        self.tagArray = tagArray
        self.dateOne = dateOne
        self.dateTwo = dateTwo
        self.eventDuration = eventDuration
        
        let nscal = Calendar.current
        var dateComponents = nscal.dateComponents([Calendar.Component.weekOfYear], from: dateOne, to: dateTwo)
        self.weeksInBetween = dateComponents.weekOfYear!
    }
    
    mutating func next() -> Date? {
        guard weeks_ptr < weeksList.count else { return nil }
        defer { slots_ptr += 1 }
        
        if openingsIndices == nil {
            encodeEventData()
            encodeTagData()
            openingsIndices = createOpeningsIndices()
        }
        
        if slotsList == nil {
            slotsList = createSlotsList()
        }
        
        /* Offset chosen opening by slot by t_i + random int b/w 0 & tgap */
        let scheduledTimeOffset = (currentOpening.lowerBound + slotsList[slots_ptr]) * Constants.timeDelta * Constants.secondsInMinute
        return firstDayOfWeek.addingTimeInterval(Double(scheduledTimeOffset))
    }
    
    private func funcName(date: Date) -> Int {
        /* Modulate the EKEvent times */
        let offset = date.timeIntervalSince(self.firstDayOfWeek)
        return Int(offset / Double(Constants.secondsInMinute * Constants.timeDelta)) % (Constants.dayLength * Constants.daysInWeek)
    }
    
    private mutating func clearTimeline() {
        timeline = Array(repeating: Availability.AVAILABLE, count: Constants.timelineLength + TERMINATOR)
        timeline[timeline.count - 1] = TERMINATOR
    }
    
    private mutating func encodeEventData() {
        var modulatedTimeArray = [CountableRange<Int>]()
        
        /* Get all scheduled events b/w firstDayOfWeek & lastDayOfWeek */
        let eventArray = eventStore.events(matching: testCompoundPredicate)
        
        for event in eventArray {
            /* Get ranges of all start-time & end-times for each event */
            let eventRange: CountableRange = self.funcName(date: event.startDate)..<self.funcName(date: event.endDate)
            modulatedTimeArray.append(eventRange)
        }
        
        for each in modulatedTimeArray {
            for every in each {
                timeline[every] |= Availability.UNAVAILABLE
            }
        }
    }
    
    private mutating func encodeTagData() {
        var timelineCount = 0
        
        for i in 0..<Constants.daysInWeek {
            for j in 0..<Constants.dayLength {
                /* Get weekday of start-day and encode */
                timeline[timelineCount] |= tagArray.arr[(dateOne.weekDay + i) % Constants.daysInWeek][j]
                timelineCount += 1
            }
        }
        
        assert(timelineCount == Constants.daysInWeek)
    }
    
    private mutating func createOpeningsIndices() -> [Int] {
        var left = -1; var right = -1; //Upper-boundary corner-case
        var list = [ClosedRange<Int>]()
        
        for i in 0..<timeline.count {
            if timeline[i] == 0 {
                right = i
            } /* Get tuples which are >= size_of_task */
            else if (left < right) {
                let cR : ClosedRange = (left+1)...right
                
                if cR.count >= eventDuration {
                    list.append(cR)
                }
                left = i
                right = i
                
            } else {
                left = i
                right = i
            }
        }
        
        openingsList = list
        openings_ptr = 0 //reset openings_ptr
        return Array(0..<list.count)//.shuffled()
    }
    
    private mutating func createSlotsList() -> [Int] {
        let tgap = (currentOpening.upperBound - currentOpening.lowerBound + 1) - eventDuration
        slots_ptr = 0 //reset slots_ptr
        return Array(0...tgap)//.shuffled()
    }
    
    /* Get first day of week being investigated by offseting with 7n days */
    private var firstDayOfWeek : Date {
        return dateOne.addingTimeInterval(Double(currentWeek * Constants.secondsInWeek))
    }
    /* Get last day of week being investigated by offseting with 7n+7 days */
    private var lastDayOfWeek : Date {
        if (currentWeek == weeksList.count - 1) {
            return dateTwo - 1
        } else {
            return firstDayOfWeek.addingTimeInterval(Double(Constants.secondsInWeek)) - 1
        }
    }
    /* Get NSPredicate for eventStore */
    private var testCompoundPredicate : NSCompoundPredicate {
        let datePredicate = eventStore.predicateForEvents(withStart: firstDayOfWeek, end: lastDayOfWeek, calendars: nil)
        let testPredicate = NSPredicate(format: "status != 'Canceled' AND isAllDay != true")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, testPredicate])
    }
    private var currentWeek : Int {
        return weeksList[weeks_ptr]
    }
    private var currentOpening : ClosedRange<Int> {
        return openingsList[openingsIndices[openings_ptr]]
    }
}
