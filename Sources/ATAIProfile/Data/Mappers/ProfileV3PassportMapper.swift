import Foundation

enum ProfileV3PassportMapper: ProfileV3DTOReading {
    static let sectionID = "passport"
    private static let expiredStatus = "expired"

    static func section(_ dto: ProfileV3AgentPassportDTO, accountCountry: ProfileV3Country?) -> ProfileV3FormSection {
        ProfileV3FormSection(
            id: sectionID,
            title: ProfileV3Strings.passportDetails,
            status: dto.verified == false ? .pending : .complete,
            control: .passport(field(dto, accountCountry: accountCountry))
        )
    }

    static func emptySection(
        _ dto: ProfileV3AgentPassportEmptyDTO,
        holderName: String?,
        accountCountry: ProfileV3Country?
    ) -> ProfileV3FormSection {
        let country = accountCountry.map(ProfileV3PassportCountry.init)
        let field = ProfileV3PassportField(
            holderName: text(holderName) ?? "",
            countryName: country?.name ?? "",
            countryNativeName: country?.nativeName,
            emptyState: ProfileV3PassportEmptyState(
                title: text(dto.title) ?? "",
                body: text(dto.body) ?? "",
                ctaLabel: text(dto.ctaLabel) ?? ""
            )
        )
        return ProfileV3FormSection(
            id: sectionID,
            title: ProfileV3Strings.passportDetails,
            status: .pending,
            control: .passport(field)
        )
    }

    static func field(_ dto: ProfileV3AgentPassportDTO, accountCountry: ProfileV3Country?) -> ProfileV3PassportField {
        let rescan = dto.rescan?.directive
        let accountFallback = rescan?.profileID == nil ? accountCountry.map(ProfileV3PassportCountry.init) : nil
        let country = text(dto.title).flatMap(ProfileV3PassportCountry.init(title:)) ?? accountFallback
        let passport = passport(dto, id: nil, country: country)
        return ProfileV3PassportField(
            holderName: passport.holderName,
            countryName: country?.name ?? "",
            countryNativeName: country?.nativeName,
            passport: passport,
            labels: labels(dto.labels, fallback: .card),
            previous: previous(dto.previous),
            rescan: rescan,
            howUsed: dto.howUsed?.directive
        )
    }

    static func previous(_ dto: ProfileV3PassportPreviousDTO?) -> ProfileV3PassportPrevious? {
        guard let label = text(dto?.label), let next = dto?.next?.directive,
              case .passportPrevious = next.route() else { return nil }
        return ProfileV3PassportPrevious(label: label, title: text(dto?.title) ?? "", next: next)
    }

    static func previousPassports(
        _ dto: ProfileV3PreviousPassportsScreenDTO,
        accountCountry: ProfileV3Country?
    ) -> ProfileV3PreviousPassports {
        let untitled = accountCountry.flatMap { $0 == .india ? nil : ProfileV3PassportCountry($0) }
        let passports = dto.passports.enumerated().map { index, row in
            passport(
                row,
                id: "\(index)-\(text(row.number) ?? "")",
                country: text(row.title).flatMap(ProfileV3PassportCountry.init(title:)) ?? untitled
            )
        }
        return ProfileV3PreviousPassports(
            title: text(dto.title) ?? "",
            labels: labels(dto.labels, fallback: .none),
            passports: passports
        )
    }

    private static func passport(
        _ dto: ProfileV3AgentPassportDTO,
        id: String?,
        country: ProfileV3PassportCountry?
    ) -> ProfileV3Passport {
        let number = text(dto.number) ?? ""
        return ProfileV3Passport(
            id: id ?? (number.isEmpty ? sectionID : number),
            holderName: text(dto.name) ?? "",
            number: number,
            countryName: country?.name ?? "",
            countryNativeName: country?.nativeName,
            issuedOn: displayDate(dto.issueDate),
            expiresOn: displayDate(dto.expiryDate),
            status: text(dto.status)?.lowercased() == expiredStatus ? .expired : .active,
            back: ProfileV3PassportBack(
                father: text(dto.father),
                mother: text(dto.mother),
                spouse: text(dto.spouse),
                address: Array(dto.address.compactMap(text).prefix(ProfileV3Theme.Counts.passportAddressLines))
            )
        )
    }

    private static func labels(
        _ dto: ProfileV3PassportLabelsDTO?,
        fallback: ProfileV3PassportLabels
    ) -> ProfileV3PassportLabels {
        ProfileV3PassportLabels(
            number: text(dto?.number) ?? "",
            issueDate: text(dto?.issueDate) ?? "",
            expiryDate: text(dto?.expiryDate) ?? "",
            father: text(dto?.father) ?? "",
            mother: text(dto?.mother) ?? "",
            spouse: text(dto?.spouse) ?? "",
            address: text(dto?.address) ?? ""
        )
        .filling(from: fallback)
    }

    static func scan(_ dto: ProfileV3PassportScanScreenDTO) -> ProfileV3PassportScan {
        ProfileV3PassportScan(
            title: text(dto.title),
            howUsed: dto.howUsed?.directive,
            front: page(dto.front),
            back: page(dto.back),
            next: dto.next?.directive ?? ProfileV3PassportScan.fallback.next
        )
    }

    static func reason(_ dto: ProfileV3PassportReasonScreenDTO) -> ProfileV3PassportReasonScreen {
        let options = dto.options.compactMap { option -> ProfileV3PassportReasonOption? in
            guard let value = text(option.value) else { return nil }
            return ProfileV3PassportReasonOption(value: value, label: text(option.label) ?? value)
        }
        return ProfileV3PassportReasonScreen(
            title: text(dto.title),
            subtitle: text(dto.subtitle),
            howUsed: dto.howUsed?.directive,
            options: options.isEmpty ? ProfileV3PassportReasonScreen.fallback.options : options,
            ctaTitle: text(dto.submit?.ctaTitle)
        )
    }

    static func howUsed(_ dto: ProfileV3PassportHowUsedScreenDTO) -> ProfileV3PassportHowUsed? {
        let steps = dto.steps.enumerated().compactMap { index, step -> ProfileV3PassportHowUsedStep? in
            guard let title = text(step.title) else { return nil }
            return ProfileV3PassportHowUsedStep(
                id: index,
                icon: text(step.icon),
                title: title,
                body: text(step.body) ?? ""
            )
        }
        guard let title = text(dto.title), !steps.isEmpty else { return nil }
        return ProfileV3PassportHowUsed(
            title: title,
            steps: steps,
            scanLabel: text(dto.scan?.label),
            scan: dto.scan?.next?.directive
        )
    }

    private static func page(_ dto: ProfileV3PassportScanSideDTO?) -> ProfileV3PassportScanPage {
        ProfileV3PassportScanPage(title: text(dto?.title), subtitle: text(dto?.subtitle))
    }

    private static func displayDate(_ raw: String?) -> String {
        guard let raw = text(raw) else { return "" }
        guard let parsed = ProfileV3AgentDateCodec.parse(raw) else { return raw }
        return ProfileV3AgentDateCodec.string(from: parsed.date, format: .dayFirst)
    }
}

struct ProfileV3PassportCountry: Equatable {
    let name: String
    let nativeName: String?

    init(_ country: ProfileV3Country) {
        if country == .india {
            name = ProfileV3Strings.passportCountryIndia
            nativeName = ProfileV3Strings.passportCountryIndiaNative
        } else {
            name = country.name.uppercased()
            nativeName = nil
        }
    }

    init?(title raw: String) {
        let title = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return nil }
        let native: Substring
        let english: Substring
        if let gap = title.range(of: #"\s{2,}"#, options: .regularExpression) {
            native = title[..<gap.lowerBound]
            english = title[gap.upperBound...]
        } else if let lastNative = title.lastIndex(where: { !$0.isASCII }) {
            let split = title[lastNative...].firstIndex(where: \.isWhitespace) ?? title.endIndex
            native = title[..<split]
            english = title[split...]
        } else {
            native = ""
            english = title[...]
        }
        let nativeName = native.trimmingCharacters(in: .whitespaces)
        let name = english.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else {
            self.name = title
            self.nativeName = nil
            return
        }
        self.name = name
        self.nativeName = nativeName.isEmpty ? nil : nativeName
    }
}

enum ProfileV3PassportScanEncoder {
    static func body(side: ProfileV3PassportSide, data: Data, profileID: String?) -> ProfileV3CaptureBody {
        let boundary = ProfileV3Multipart.generateBoundary()
        var fields = [ProfileV3Multipart.Field(name: "side", value: side.rawValue)]
        if let profileID { fields.append(ProfileV3Multipart.Field(name: "profile_id", value: profileID)) }
        let file = ProfileV3Multipart.FileField(
            name: "file",
            fileName: "passport_\(side.rawValue).jpg",
            mimeType: "image/jpeg",
            data: data
        )
        let body = ProfileV3Multipart.buildBody(boundary: boundary, fields: fields, files: [file])
        return ProfileV3CaptureBody(data: body, contentType: "multipart/form-data; boundary=\(boundary)")
    }
}
