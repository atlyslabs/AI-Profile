import SwiftUI

struct ProfileV3AmbientSchedule: TimelineSchedule {
    var isPaused = false

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
        guard !isPaused else { return AnyIterator(CollectionOfOne(startDate).makeIterator()) }
        let interval = ProfileV3Theme.Motion.ambientFrameInterval
        var tick = (startDate.timeIntervalSinceReferenceDate / interval).rounded(.down)
        return AnyIterator {
            defer { tick += 1 }
            return Date(timeIntervalSinceReferenceDate: tick * interval)
        }
    }
}
