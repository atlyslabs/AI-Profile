import CoreGraphics
import Testing
@testable import ATAIProfile

@Suite("Instagram motion")
struct ProfileV3InstagramMotionTests {
    @Test func keyframesHoldThenEaseIntoEachStop() {
        let track = ProfileV3Keyframes(2).hold(until: 1).to(4, at: 3, .easeInOut).to(0, at: 4)
        #expect(track.end == 4)
        #expect(track.value(at: -1) == 2)
        #expect(track.value(at: 0.5) == 2)
        #expect(abs(track.value(at: 2) - 3) < 0.001)
        #expect(track.value(at: 3) == 4)
        #expect(track.value(at: 3.5) == 2)
        #expect(track.value(at: 9) == 0)
    }

    @Test func theReelsFlyIntoTheMapBeforeThePlaceCardLands() throws {
        typealias Motion = ProfileV3Theme.Motion.InstagramIntro
        let reels = ProfileV3Theme.Sizes.InstagramConnect.introReels
        #expect(reels.count == 5)
        for reel in reels {
            #expect(reel.pose(at: 0) == reel.restingPose)
            let landed = reel.pose(at: Motion.seconds)
            #expect(abs(landed.position.x - reel.target.x) < 0.001)
            #expect(abs(landed.position.y - reel.target.y) < 0.001)
            #expect(abs(landed.rotation) < 0.001)
            #expect(abs(landed.scale - Motion.reelEndScale) < 0.001)
            #expect(landed.opacity == 0)
        }

        let aurora = reels.first { $0.art == .aurora }
        let london = reels.first { $0.art == .london }
        let first = try #require(aurora)
        let last = try #require(london)
        #expect(first.pose(at: 0.5).scale < 1)
        #expect(last.pose(at: 0.5) == last.restingPose)

        #expect(Motion.mapOpacity.value(at: 0) == 0.06)
        #expect(Motion.mapOpacity.value(at: Motion.seconds) == 1)
        #expect(Motion.placeOpacity.value(at: 1.9) == 0)
        #expect(Motion.placeOpacity.value(at: Motion.seconds) == 1)
        #expect(Motion.placeScale.value(at: Motion.seconds) == 1)
        #expect(Motion.placeRise.value(at: Motion.seconds) == 0)
    }

    @Test func theOrbAssemblesFromItsParticles() {
        typealias Motion = ProfileV3Theme.Motion.AylOrbAssembly
        let particles = ProfileV3Theme.Sizes.InstagramConnect.orbParticles
        let light = particles.filter(\.isLight)
        #expect(particles.count == 44)
        #expect(light.count == 11)
        for particle in particles {
            #expect(particle.position(at: 0) == CGPoint(x: particle.rest.x + particle.start.width, y: particle.rest.y + particle.start.height))
            #expect(particle.position(at: Motion.seconds) == particle.rest)
            #expect(particle.opacity(at: 0) == 0)
            #expect(particle.opacity(at: 1) > 0.5)
            #expect(particle.opacity(at: Motion.seconds) == 0)
        }
        #expect(Motion.blur.value(at: 0) == 48)
        #expect(Motion.blur.value(at: Motion.seconds) == 0)
        #expect(Motion.orbOpacity.value(at: Motion.seconds) == 1)
        #expect(Motion.limeOpacity.value(at: Motion.seconds) == 1)
        #expect(Motion.scale.value(at: Motion.seconds) == 1)
    }
}
