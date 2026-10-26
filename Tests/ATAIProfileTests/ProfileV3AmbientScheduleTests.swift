import Foundation
import SwiftUI
import Testing
@testable import ATAIProfile

@Suite("Ambient frame clock")
struct ProfileV3AmbientScheduleTests {
    private let interval = ProfileV3Theme.Motion.ambientFrameInterval

    @Test func timelinesStartedApartTickTogether() {
        let early = Date(timeIntervalSinceReferenceDate: 1_000.013)
        let late = Date(timeIntervalSinceReferenceDate: 1_000.05)
        let first = Array(ProfileV3AmbientSchedule().entries(from: early, mode: .normal).prefix(4))
        let second = Array(ProfileV3AmbientSchedule().entries(from: late, mode: .normal).prefix(4))

        #expect(first.first.map { $0 <= early } == true)
        #expect(second.first.map { $0 <= late } == true)
        for pair in zip(first, first.dropFirst()) {
            #expect(abs(pair.1.timeIntervalSince(pair.0) - interval) < 1e-9)
        }
        #expect(Set(first).intersection(second).count == 3)
    }

    @Test func aPausedTimelineHoldsItsFrame() {
        let start = Date(timeIntervalSinceReferenceDate: 500.5)
        let entries = Array(ProfileV3AmbientSchedule(isPaused: true).entries(from: start, mode: .normal))
        #expect(entries == [start])
    }

    @Test func theClockRunsAt24FramesASecond() {
        #expect(abs(1 / interval - 24) < 1e-9)
    }
}
