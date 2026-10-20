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

    private func rounded(_ rgb: Wave.RGB) -> Wave.RGB {
        Wave.RGB(rgb.red.rounded(), rgb.green.rounded(), rgb.blue.rounded())
    }
}
