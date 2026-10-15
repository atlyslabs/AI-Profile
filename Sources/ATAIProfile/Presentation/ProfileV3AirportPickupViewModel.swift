import Combine
import SwiftUI

@MainActor
final class ProfileV3AirportPickupViewModel: ObservableObject, Identifiable {
    @Published private(set) var cars: ProfileV3CarField
    @Published private(set) var isConfirming = false
    @Published private(set) var isStaged = false

    let agentTag: String
    let avatarURL: URL?
    let autoLaunches: Bool
    let picker: ProfileV3RidePicker?

    private let region: String?
    private let initialSelection: String?
    private let onConfirm: (String) -> Void
    private let onFinish: () -> Void
    private var stageTask: Task<Void, Never>?

    init(
        cars: ProfileV3CarField,
        agentTag: String,
        avatarURL: URL?,
        picker: ProfileV3RidePicker? = nil,
        region: String? = nil,
        autoLaunches: Bool = ProfileV3Theme.Motion.pickupAutoLaunches,
        onConfirm: @escaping (String) -> Void = { _ in },
        onFinish: @escaping () -> Void
    ) {
        self.cars = cars
        self.agentTag = agentTag
        self.avatarURL = avatarURL
        self.picker = picker
        self.region = region
        self.autoLaunches = autoLaunches
        initialSelection = cars.selection
        self.onConfirm = onConfirm
        self.onFinish = onFinish
    }

    var title: String {
        autoLaunches ? ProfileV3Strings.stagingAirportPickup : picker?.title ?? ProfileV3Strings.selectAirportPickup
    }

    var subtitle: String { picker?.subtitle ?? ProfileV3Strings.airportPickupSubtitle }

    var note: String { picker?.note ?? ProfileV3Strings.airportPickupNote }

    var footer: String { picker?.footer ?? ProfileV3Strings.carIncluded }

    var isEligible: Bool { picker?.isEligible(region: region) ?? true }

    func brand(for car: ProfileV3CarOption) -> String? { option(for: car)?.brand }

    func spec(for car: ProfileV3CarOption) -> String? { option(for: car)?.spec }

    func stageImageURL(for car: ProfileV3CarOption) -> URL? { option(for: car)?.imageURL ?? car.stageImageURL }

    private func option(for car: ProfileV3CarOption) -> ProfileV3RideOption? {
        picker?.options.first { $0.id == car.id }
    }

    func start() {
        guard autoLaunches, stageTask == nil else { return }
        launch(delayMilliseconds: ProfileV3Theme.Motion.pickupAutoLaunchMilliseconds, pauseMilliseconds: 0)
    }

    func select(_ carID: String) {
        guard !isConfirming, cars.selection != carID, cars.options.contains(where: { $0.id == carID }) else {
            return
        }
        cars.selection = carID
    }

    func confirm() {
        guard !isConfirming, isEligible else { return }
        launch(delayMilliseconds: 0, pauseMilliseconds: ProfileV3Theme.Motion.launchDelayMilliseconds)
    }

    private func launch(delayMilliseconds: Int, pauseMilliseconds: Int) {
        stageTask?.cancel()
        stageTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(for: .milliseconds(delayMilliseconds))
                isConfirming = true
                try await Task.sleep(for: .milliseconds(pauseMilliseconds))
                isStaged = true
                if let carID = cars.selection, carID != initialSelection {
                    onConfirm(carID)
                }
                try await Task.sleep(for: .milliseconds(ProfileV3Theme.Motion.stagedDismissMilliseconds))
                onFinish()
            } catch {
                return
            }
        }
    }

    func tapBack() {
        stageTask?.cancel()
        onFinish()
    }

    func cancelPendingWork() {
        stageTask?.cancel()
    }
}

#if DEBUG
extension ProfileV3AirportPickupViewModel {
    static func preview(
        autoLaunches: Bool = false,
        isConfirming: Bool = false,
        isStaged: Bool = false
    ) -> ProfileV3AirportPickupViewModel {
        let viewModel = ProfileV3AirportPickupViewModel(
            cars: ProfileV3AgentFixtures.airportCars,
            agentTag: "Airport logistics",
            avatarURL: ProfileV3PlaceholderArt.agent(id: ProfileV3AgentID.airportLogistics.rawValue)?.url,
            autoLaunches: autoLaunches,
            onFinish: {}
        )
        viewModel.isConfirming = isConfirming
        viewModel.isStaged = isStaged
        return viewModel
    }
}
#endif
