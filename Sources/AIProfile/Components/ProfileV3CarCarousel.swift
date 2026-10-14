import ATUIKit
import SwiftUI

struct ProfileV3CarCarousel: View {
    let field: ProfileV3CarField
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ProfileV3Theme.Sizes.Car.cardSpacing) {
                ForEach(field.options) { car in
                    ProfileV3CarCard(car: car, isSelected: field.selection == car.id) { onSelect(car.id) }
                }
            }
        }
        .contentMargins(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin, for: .scrollContent)
        .scrollClipDisabled()
        .padding(.horizontal, -ProfileV3Theme.Sizes.screenHorizontalMargin)
    }
}

private struct ProfileV3CarCard: View {
    let car: ProfileV3CarOption
    let isSelected: Bool
    let action: () -> Void

    private typealias Sizes = ProfileV3Theme.Sizes.Car

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Sizes.cornerRadius, style: .continuous)
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                ProfileV3RemoteImage(url: car.imageURL, contentMode: .fill, placeholder: .clear)
                    .frame(width: Sizes.cardWidth, height: Sizes.cardHeight)
                Text(car.name)
                    .typoGraphy(.H7DentonBold16)
                    .foregroundStyle(Color(at: .pureBlack))
                    .lineLimit(2)
                    .frame(width: Sizes.nameWidth, alignment: .leading)
                    .padding(.leading, Sizes.nameLeading)
                    .padding(.top, Sizes.nameTop)
            }
            .frame(width: Sizes.cardWidth, height: Sizes.cardHeight, alignment: .topLeading)
            .clipShape(shape)
            .profileV3TileChrome(
                shape,
                border: isSelected ? Color(at: .pureBlack) : ProfileV3Theme.Palette.optionTileBorder
            )
            .animation(ProfileV3Theme.Motion.selection, value: isSelected)
        }
        .buttonStyle(.profileV3Pressable(.selection))
        .accessibilityLabel(car.name)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#if DEBUG
private struct ProfileV3CarCarouselPreview: View {
    @State private var field = ProfileV3CarField(
        options: [
            ProfileV3CarOption(
                id: "tesla_cybertruck",
                name: "Tesla Cybertruck",
                imageURL: URL(string: "https://media.atlys.com/b2c/ai-native/cars/side/tesla_cybertruck.png")
            ),
            ProfileV3CarOption(
                id: "ferrari_296_gtb",
                name: "Ferrari 296 GTB",
                imageURL: URL(string: "https://media.atlys.com/b2c/ai-native/cars/side/ferrari_296_gtb.png")
            ),
            ProfileV3CarOption(
                id: "ford_mustang",
                name: "Ford Mustang",
                imageURL: URL(string: "https://media.atlys.com/b2c/ai-native/cars/side/ford_mustang.png")
            )
        ],
        selection: "tesla_cybertruck"
    )

    var body: some View {
        ProfileV3CarCarousel(field: field) { field.selection = $0 }
            .padding(.horizontal, ProfileV3Theme.Sizes.screenHorizontalMargin)
            .padding(.vertical, ProfileV3Theme.Space.s32)
            .background(Color(at: .pureWhite))
    }
}

#Preview("Car carousel") {
    ProfileV3CarCarouselPreview()
}
#endif
