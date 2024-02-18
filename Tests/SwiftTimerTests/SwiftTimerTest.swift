//
//  TimerSequenceManagerTest.swift
//  
//
//  Created by Nate Smith on 2/17/24.
//

import XCTest
@testable import SwiftTimer

@available(iOS 17.0, *)
final class SwiftTimerTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        timerSequenceManager = TimerSequence.shared
    }

    override func tearDownWithError() throws {
        timerSequenceManager = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    var timerSequenceManager: TimerSequence!
        
//    override func setUp() {
//        super.setUp()
//    }
    
//    override func tearDown() {
//        super.tearDown()
//    }
    
    func testAddTimer() {
        let timer = TimerItem(duration: 60, category: "Test", title: "Test Timer")
        timerSequenceManager.addTimer(timer)
        XCTAssertFalse(timerSequenceManager.currentState.timers.isEmpty, "Timer should be added")
    }
    
    func testStartTimer() {
        let timer = TimerItem(duration: 60, category: "Test", title: "Test Timer")
        timerSequenceManager.addTimer(timer)
        timerSequenceManager.startTimer(timer)
//        XCTAssertEqual(timerSequenceManager.timerManager.timerState, .running, "Timer should be running")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
