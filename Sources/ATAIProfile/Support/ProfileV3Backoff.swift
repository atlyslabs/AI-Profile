import Foundation

@MainActor
enum ProfileV3Backoff {
    struct Schedule {
        let attempts: Int
        let initialMilliseconds: Int
        let minimumMilliseconds: Int
        let maximumMilliseconds: Int
        let growth: Int

        static let refresh = Schedule(
            attempts: 6,
            initialMilliseconds: 1_000,
            minimumMilliseconds: 1_000,
            maximumMilliseconds: 8_000,
            growth: 2
        )
        static let connector = Schedule(
            attempts: 60,
            initialMilliseconds: 2_000,
            minimumMilliseconds: 500,
            maximumMilliseconds: 10_000,
            growth: 1
        )
        static let passportBack = Schedule(
            attempts: 4,
            initialMilliseconds: 1_500,
            minimumMilliseconds: 1_500,
            maximumMilliseconds: 1_500,
            growth: 1
        )

        func clamped(_ milliseconds: Int) -> Int {
            min(max(milliseconds, minimumMilliseconds), maximumMilliseconds)
        }
    }

    static func poll(
        _ schedule: Schedule = .refresh,
        startsImmediately: Bool = false,
        suggestedMilliseconds: () -> Int? = { nil },
        until settled: () async -> Bool
    ) async {
        if startsImmediately, await settled() { return }
        var delay = schedule.initialMilliseconds
        for _ in 0 ..< schedule.attempts {
            try? await Task.sleep(for: .milliseconds(schedule.clamped(suggestedMilliseconds() ?? delay)))
            guard !Task.isCancelled else { return }
            if await settled() { return }
            delay = schedule.clamped(delay * schedule.growth)
        }
    }

    static func retry<Value>(
        _ schedule: Schedule,
        while isRetryable: (Error) -> Bool,
        operation: () async throws -> Value
    ) async throws -> Value {
        var delay = schedule.initialMilliseconds
        for _ in 1 ..< schedule.attempts {
            do {
                return try await operation()
            } catch let error where isRetryable(error) {
                try await Task.sleep(for: .milliseconds(delay))
                delay = schedule.clamped(delay * schedule.growth)
            }
        }
        return try await operation()
    }
}
