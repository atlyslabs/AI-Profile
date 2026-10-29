import Testing
@testable import ATAIProfile

@Suite("Persona processing")
struct ProfileV3PersonaProcessingTests {
    private typealias Wave = ProfileV3PersonaWave

    @Test func waveMatchesTheBoardKeyframes() {
        let adventure = 0.63541
        #expect(rounded(Wave.rgb(at: adventure, start: adventure)) == Wave.base)
        #expect(rounded(Wave.rgb(at: adventure + 0.0375, start: adventure)) == Wave.RGB(110, 61, 224))
        #expect(rounded(Wave.rgb(at: adventure + 0.085, start: adventure)) == Wave.RGB(245, 166, 209))
        #expect(rounded(Wave.rgb(at: adventure + 0.2, start: adventure)) == Wave.base)
        #expect(rounded(Wave.rgb(at: 0.2, start: adventure)) == Wave.base)
    }

    @Test func waveWrapsAcrossTheLoop() {
        #expect(close(Wave.rgb(at: 0, start: 0.94665), Wave.RGB(167, 51, 186)))
        #expect(close(Wave.rgb(at: 0, start: 0.85256), Wave.RGB(56, 28, 62)))
        #expect(close(Wave.rgb(at: 0.0129, start: 0.94665), Wave.RGB(214, 42, 156)))
    }

    private func close(_ rgb: Wave.RGB, _ expected: Wave.RGB) -> Bool {
        abs(rgb.red - expected.red) <= 1 && abs(rgb.green - expected.green) <= 1 && abs(rgb.blue - expected.blue) <= 1
    }

    @Test func tenSlotsRunClockwiseFromTheTop() {
        let slots = ProfileV3PersonaProcessingSlot.all
        #expect(slots.count == 10)
        #expect(slots.first?.alignment == .center)
        #expect(slots[5].alignment == .center)
        #expect(slots[1...4].allSatisfy { $0.alignment == .leading })
        #expect(slots[6...9].allSatisfy { $0.alignment == .trailing })
        #expect(slots.map(\.top) == [0, 23, 97, 185, 253, 275, 253, 185, 97, 23])
    }

    @Test func hapticsTickEachLabelAsTheWaveLightsItOnceItHasAppeared() {
        let loop = ProfileV3Theme.Motion.personaProcessingLoop
        let slots = ProfileV3PersonaProcessingSlot.all
        var ticks: [Double] = []
        var elapsed = 0.0
        for _ in 0 ..< 30 {
            elapsed = Wave.nextPeak(after: elapsed)
            ticks.append(elapsed)
        }

        #expect(zip(ticks, ticks.dropFirst()).allSatisfy { $0 < $1 })
        #expect(abs(ticks[0] - 1.62576) < 0.001)
        for tick in ticks {
            let phase = tick / loop
            let lit = slots.indices.filter { index in
                var offset = phase - slots[index].waveStart - Wave.peak
                offset -= offset.rounded()
                return abs(offset) < 1e-9 && tick >= ProfileV3PersonaProcessingSlot.entranceDelay(index)
            }
            #expect(lit.count == 1)
            #expect(rounded(Wave.rgb(at: phase - phase.rounded(.down), start: slots[lit.first ?? 0].waveStart))
                == Wave.RGB(245, 166, 209))
        }
        #expect(ticks.filter { $0 < loop }.count == 6)
        #expect(ticks.filter { $0 >= loop && $0 < 2 * loop }.count == slots.count)
        #expect(ticks.filter { $0 >= 2 * loop && $0 < 3 * loop }.count == slots.count)
    }

    private func rounded(_ rgb: Wave.RGB) -> Wave.RGB {
        Wave.RGB(rgb.red.rounded(), rgb.green.rounded(), rgb.blue.rounded())
    }
}
