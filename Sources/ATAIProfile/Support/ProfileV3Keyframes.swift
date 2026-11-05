import SwiftUI

struct ProfileV3Keyframes: Sendable {
    private struct Stop: Sendable {
        let time: TimeInterval
        let value: Double
        let curve: UnitCurve
    }

    private var stops: [Stop]

    init(_ value: Double) {
        stops = [Stop(time: 0, value: value, curve: .linear)]
    }

    var end: TimeInterval { stops[stops.count - 1].time }

    func hold(until time: TimeInterval) -> Self {
        to(stops[stops.count - 1].value, at: time)
    }

    func to(_ value: Double, at time: TimeInterval, _ curve: UnitCurve = .linear) -> Self {
        var track = self
        track.stops.append(Stop(time: time, value: value, curve: curve))
        return track
    }

    func value(at elapsed: TimeInterval) -> Double {
        var previous = stops[0]
        for stop in stops.dropFirst() {
            guard elapsed >= stop.time else {
                let span = stop.time - previous.time
                let progress = span > 0 ? max(0, (elapsed - previous.time) / span) : 1
                return previous.value + (stop.value - previous.value) * stop.curve.value(at: progress)
            }
            previous = stop
        }
        return previous.value
    }
}
