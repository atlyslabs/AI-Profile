import Foundation

#if DEBUG
enum ProfileV3AgentFixtures {

    static let flows: [String: ProfileV3AgentFlow] = [
        ProfileV3AgentID.flight.rawValue: .preferences(flight),
        ProfileV3AgentID.stay.rawValue: .preferences(stay),
        ProfileV3AgentID.airportLogistics.rawValue: .preferences(airportLogistics),
        ProfileV3AgentID.food.rawValue: .preferences(food),
        ProfileV3AgentID.medical.rawValue: .preferences(medical),
        ProfileV3AgentID.itinerary.rawValue: .preferences(itinerary),
        ProfileV3AgentID.personal.rawValue: .preferences(personal)
    ]

    static func customRulesField(_ rules: [String]) -> ProfileV3CustomRulesField {
        ProfileV3CustomRulesField(
            rules: rules,
            addLabel: "Custom",
            editor: ProfileV3CustomRulesField.Editor(
                addTitle: "Add a rule",
                editTitle: "Edit a rule",
                noteLabel: "NOTE",
                saveLabel: "Save",
                savedToast: "Custom rule saved",
                maxCharacters: 500
            ),
            deleteConfirm: ProfileV3CustomRulesField.DeleteConfirm(
                title: "Are you sure you want to delete your rule",
                confirmLabel: "Delete",
                cancelLabel: "Keep rule"
            ),
            maxRules: 20
        )
    }

    static func customRulesSection(_ rules: [String]) -> ProfileV3FormSection {
        ProfileV3FormSection(
            id: "custom_rules",
            title: "CUSTOM RULES",
            status: rules.isEmpty ? .pending : .complete,
            control: .customRules(customRulesField(rules))
        )
    }

    static let sources = ProfileV3FormSources(
        icons: [],
        count: 3
    )

    static let airlines: [ProfileV3ChipOption] = [
        option("Singapore Airlines"),
        option("Emirates"),
        option("Etihad"),
        option("Thai Airways"),
        option("Turkish Airlines"),
        option("Qatar Airways"),
        option("Air India")
    ]

    static let hotels: [ProfileV3ChipOption] = [
        option("Taj"),
        option("Marriott"),
        option("Hyatt"),
        option("Hilton"),
        option("Four Seasons"),
        option("Oberoi"),
        option("Accor")
    ]

    static let flight = ProfileV3AgentForm(
        agentID: ProfileV3AgentID.flight.rawValue,
        agentTag: "Flight agent",
        foundCount: 6,
        totalCount: 8,
        noun: "flight",
        summary: "You\u{2019}ve flown Emirates to Dubai three times in the past year, "
            + "and you\u{2019}ve chosen an aisle seat every time.",
        sources: sources,
        sections: [
            chips(
                "airlines", "Airlines", status: .complete,
                options: ["Cheapest"], selected: ["Singapore Airlines", "Emirates"],
                picker: ProfileV3OptionPicker(title: "+Add preferred airlines", catalogue: airlines),
                note: "...I will scan flights 24x7 and get you the best deals",
                source: ProfileV3SectionSource(
                    icons: [ProfileV3SourceIcon(url: gmailSourceIcon), ProfileV3SourceIcon(url: emiratesSourceIcon)],
                    count: 3,
                    agentType: "flight",
                    fieldKey: "airlines"
                )
            ),
            chips(
                "class", "Class",
                options: ["Economy", "Premium economy", "Business", "First class"],
                selected: ["Economy", "Premium economy"],
                note: "...I will scan flights 24x7 and get you the best deals"
            ),
            chips(
                "seat", "Seat", status: .complete,
                options: ["Window", "Middle", "Aisle", "Extra legroom", "Cheapest"], selected: ["Window", "Cheapest"],
                note: "...I will look for the cheapest window seat, if not available I\u{2019}ll find the cheapest one"
            ),
            cards(
                "airline-meal", "Airline meal", status: .complete,
                options: [
                    ("AVML", "vegetarian (asian)"), ("VGML", "vegan, no animal products"),
                    ("VJML", "jain-no root veggies"), ("MOML", "halal/muslim meal"),
                    ("KSML", "kosher, sealed on board"), ("GFML", "gluten free"),
                    ("SFML", "seafood"), ("DBML", "diabetic-friendly")
                ],
                selected: ["AVML"],
                note: "...I will pre-book this meal on every flight"
            ),
            chips(
                "allergies", "Allergies", status: .pending,
                options: ["Peanuts", "Tree nuts", "Dairy", "Gluten", "Shellfish", "Soy"],
                note: "...I\u{2019}ll flag these to the airlines"
            ),
            slider(
                "flying-hours", "Flying hours",
                ProfileV3SliderField(value: 10, range: 1...18, format: .unit("hrs max")),
                note: "...basis previous 3 flights, 6 emails", noteIcon: .sources
            ),
            chips(
                "flight-timings", "Flight timings",
                options: ["Early morning", "Morning", "Afternoon", "Evening", "Night", "Late night"],
                note: "...basis previous 3 flights, 6 emails", noteIcon: .sources
            ),
            chips(
                "stops", "Stops",
                options: ["Non-stop", "1-stop", "> 1 stop", "Cheapest"], selected: ["1-stop", "Cheapest"],
                note: "...I will look for cheapest flights with a maximum of 1 stop"
            ),
            customRulesSection(["Always book a window seat on red-eye flights", "Avoid layovers longer than 3 hours"])
        ]
    )

    static let stay = ProfileV3AgentForm(
        agentID: ProfileV3AgentID.stay.rawValue,
        agentTag: "Stay agent",
        foundCount: 6,
        totalCount: 8,
        noun: "stay",
        summary: pulledTogetherSummary,
        sources: sources,
        sections: [
            chips(
                "preferred-hotels", "Preferred hotels", status: .complete,
                options: [], selected: ["Taj", "Marriott"],
                picker: ProfileV3OptionPicker(title: "+Add preferred hotels", catalogue: hotels),
                note: "...I will match these chains first and fall back to the best-rated stay"
            ),
            chips(
                "property-type", "Property type", status: .complete,
                options: [
                    "Hotel", "Boutique hotel", "Resort", "Serviced apartment", "Hostel", "Homestay",
                    "Close to the city center"
                ],
                selected: ["Hotel", "Boutique hotel"],
                note: "...I will shortlist stays that match this style"
            ),
            chips(
                "rooms", "Rooms", status: .complete,
                options: ["High floor", "Low floor", "Quiet room", "King bed", "Twin beds", "Non-smoking"],
                selected: ["High floor", "Low floor"],
                note: "...I will request these at booking and again before check-in"
            ),
            chips(
                "amenities", "Must have amenities", status: .complete,
                options: [
                    "Fast Wifi", "Breakfast", "Gym", "Swimming pool", "Spa", "Kitchen", "Laundry", "Kids play area"
                ],
                selected: ["Fast Wifi", "Kitchen", "Laundry", "Kids play area"],
                note: "...I will only surface stays that have all of these"
            ),
            customRulesSection([])
        ]
    )

    static let itinerary = ProfileV3AgentForm(
        agentID: ProfileV3AgentID.itinerary.rawValue,
        agentTag: "Itinerary agent",
        foundCount: 6,
        totalCount: 8,
        noun: "itinerary",
        summary: pulledTogetherSummary,
        sources: sources,
        sections: [
            chips(
                "activities", "Activities", status: .complete,
                options: [
                    "Food", "History", "Nature", "Nightlife", "Shopping", "Wellness", "Adventures", "Art",
                    "Photography", "Sports", "Museums"
                ],
                selected: ["Food", "History", "Shopping"],
                note: "...I will build days around these first"
            ),
            chips(
                "getting-around", "Getting around", status: .complete,
                options: [
                    "Public transport", "Private", "Self-drive", "Prefer walking short distances", "Most efficient"
                ],
                selected: ["Public transport", "Private"],
                note: "...I will plan transfers the way you like to move"
            ),
            slider(
                "trip-pacing", "Trip pacing", status: .complete,
                ProfileV3SliderField(value: 1, range: 0...2, style: .labels(["Relaxed", "Balanced", "Packed"])),
                note: "...I will leave breathing room between plans"
            ),
            customRulesSection([])
        ]
    )

    static let medical = ProfileV3AgentForm(
        agentID: ProfileV3AgentID.medical.rawValue,
        agentTag: "Medical agent",
        foundCount: 6,
        totalCount: 8,
        noun: "medical",
        summary: pulledTogetherSummary,
        sources: sources,
        medicalCard: ProfileV3MedicalCard(
            holderName: "alex r.",
            countryCode: "IN",
            dateOfBirth: "01.01.1990",
            bloodGroup: "O+",
            emergencyContact: "+91 9000000003",
            organDonor: ProfileV3Strings.yes,
            showsOnLockScreen: true,
            bloodGroupSectionID: "blood-type",
            emergencyContactSectionID: "emergency-contact"
        ),
        sections: [
            chips(
                "blood-type", "Blood type", status: .complete,
                options: ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"], selected: ["B+"], allowsMultiple: false,
                note: "...I will keep this on your medical card"
            ),
            text(
                "emergency-contact", "Emergency contact", status: .complete,
                ProfileV3TextFieldValue(value: "+91 9000000002", placeholder: "+91", keyboard: .phone),
                note: "...I will share this with hospitals only in an emergency"
            ),
            chips(
                "allergies", "Allergies", status: .complete,
                options: ["Peanuts", "Shellfish", "Tree nuts", "Dairy", "Gluten", "Latex", "Penicillin"],
                selected: ["Peanuts", "Shellfish"],
                picker: ProfileV3OptionPicker(
                    title: "+Add allergies",
                    catalogue: [
                        "Soy", "Eggs", "Sesame", "Wheat", "Sulfites", "Aspirin", "Bee stings"
                    ].map { option($0) }
                ),
                note: "...I will flag these to airlines, hotels and restaurants"
            ),
            slider(
                "height", "Height", status: .complete,
                ProfileV3SliderField(
                    value: 183, range: 150...210, format: .centimetres,
                    optOut: ProfileV3OptOut(title: ProfileV3Strings.ratherNotSay, isOn: false)
                ),
                note: "...I will use this for seat and insurance fit"
            ),
            slider(
                "weight", "Weight", status: .complete,
                ProfileV3SliderField(
                    value: 74, range: 40...120, format: .unit("kg"),
                    optOut: ProfileV3OptOut(title: ProfileV3Strings.ratherNotSay, isOn: true)
                ),
                note: "...I will use this for insurance quotes only"
            ),
            chips(
                "conditions", "Conditions", status: .complete,
                options: [
                    "Type 1 diabetes", "Type 2 diabetes", "Asthma", "Epilepsy", "Heart condition",
                    "High blood pressure", "Pregnancy", "Recent surgeries"
                ],
                selected: ["Type 1 diabetes", "Type 2 diabetes"],
                picker: ProfileV3OptionPicker(
                    title: "+Add conditions",
                    catalogue: ["Thyroid", "Migraine", "Arthritis", "Anaemia", "Kidney condition"].map { option($0) }
                ),
                note: "...I will keep medication reminders and pharmacies handy"
            ),
            chips(
                "assistance", "Assistance needed", status: .complete,
                options: [
                    "Own wheelchair", "Wheelchair to gate (Airport)", "Visual assistance (blind)",
                    "Hearing assistance (deaf)", "Heart condition", "Service animal"
                ],
                selected: ["Own wheelchair", "Wheelchair to gate (Airport)"],
                picker: ProfileV3OptionPicker(
                    title: "+Add assistance",
                    catalogue: [
                        "Oxygen on board", "Stretcher", "Meet and assist", "Priority boarding"
                    ].map { option($0) }
                ),
                note: "...I will request assistance at every airport"
            )
        ]
    )

    static let food = ProfileV3AgentForm(
        agentID: ProfileV3AgentID.food.rawValue,
        agentTag: "Food agent",
        foundCount: 6,
        totalCount: 8,
        noun: "food",
        summary: pulledTogetherSummary,
        sources: sources,
        sections: [
            chips(
                "dietary-style", "Dietary style", status: .complete,
                options: ["Vegetarian", "Vegan", "Pescetarian", "Jain", "Halal", "Kosher", "Gluten-free", "Keto"],
                selected: ["Vegetarian", "Vegan", "Halal"],
                picker: ProfileV3OptionPicker(
                    title: "+Add dietary style",
                    catalogue: ["Paleo", "Low carb", "Dairy-free", "Nut-free"].map { option($0) }
                ),
                note: "...I will filter menus and meals to match"
            ),
            chips(
                "allergies", "Allergies", status: .pending,
                options: ["Peanuts", "Tree nuts", "Dairy", "Gluten", "Shellfish", "Soy"],
                note: "...I\u{2019}ll flag these to restaurants"
            ),
            slider(
                "spice", "Spice levels", status: .complete,
                ProfileV3SliderField(
                    value: 2, range: 0...4, style: .labels(["sober", "super spicy"]),
                    format: .levels(["Sober", "Mild", "Medium spicy", "Spicy", "Super spicy"])
                ),
                note: "...I will ask kitchens to tune the heat"
            ),
            chips(
                "cuisines", "Cuisines you love", status: .complete,
                options: [
                    "Indian", "Japanese", "Thai", "Italian", "Mediterranean", "Mexican", "Middle Eastern", "French"
                ],
                selected: ["Indian", "Mexican", "Middle Eastern", "French"],
                picker: ProfileV3OptionPicker(
                    title: "+Add cuisines",
                    catalogue: ["Korean", "Vietnamese", "Spanish", "Greek", "Peruvian", "Ethiopian"].map { option($0) }
                ),
                note: "...I will look for the best-rated places nearby"
            ),
            chips(
                "dislikes", "Dislikes", status: .complete,
                options: [
                    "Seafood", "Eggs", "Red meat - beef", "Red meat - pork", "Onion & Garlic"
                ], selected: ["Seafood"],
                picker: ProfileV3OptionPicker(
                    title: "+Add dislikes",
                    catalogue: ["Mushrooms", "Coriander", "Olives", "Cheese", "Offal"].map { option($0) }
                ),
                note: "...I will keep these off your plate"
            ),
            chips(
                "drinks", "Drinks", status: .complete,
                options: [
                    "Wine", "Beer", "Spirits", "Non-alcoholic", "Sugar free", "Coffee", "Tea"
                ], selected: ["Wine"],
                picker: ProfileV3OptionPicker(
                    title: "+Add drinks",
                    catalogue: ["Cocktails", "Sake", "Kombucha", "Fresh juice"].map { option($0) }
                ),
                note: "...I will note this for lounges and dinners"
            ),
            chips(
                "dining-style", "Dining style", status: .complete,
                options: [
                    "Room service", "Buffet", "\u{00C0} la carte", "Quiet table", "Window table", "Early dining",
                    "Late dining", "Healthy", "Fine dine", "Street food"
                ],
                selected: ["Room service"],
                picker: ProfileV3OptionPicker(
                    title: "+Add dining style",
                    catalogue: ["Chef\u{2019}s table", "Rooftop", "Family style", "Tasting menu"].map { option($0) }
                ),
                note: "...I will reserve tables the way you like them"
            ),
            slider(
                "open-to-trying", "Open to trying out food", status: .complete,
                ProfileV3SliderField(
                    value: 3, range: 0...4, style: .labels(["safe", "experimental"]),
                    format: .levels(["Play it safe", "Cautious", "Curious", "Open to trying", "Experimental"])
                ),
                note: "...I will slip in one new place per trip"
            ),
            customRulesSection(["Pick a veg restaurant every time Aakanksha is on the trip. Make sure the veg food doesn’t have egg"])
        ]
    )

    static let personal = ProfileV3AgentForm(
        agentID: ProfileV3AgentID.personal.rawValue,
        agentTag: "Personal agent",
        foundCount: 6,
        totalCount: 8,
        noun: "personal",
        summary: pulledTogetherSummary,
        sources: sources,
        sections: [
            passport(
                "passport", ProfileV3Strings.passportDetails,
                passport: ProfileV3PassportFixtures.active,
                previous: ProfileV3PassportFixtures.previousEntry
            ),
            chips(
                "travelling-with", "Traveling with", status: .complete,
                options: ["Solo", "Partner", "Family", "Friends", "Colleagues"], selected: ["Solo"],
                note: "...I will size rooms, tables and transfers accordingly"
            ),
            chips(
                "trip-purpose", "Trip purpose", status: .complete,
                options: ["Leisure", "Business", "Bleisure"], selected: ["Leisure", "Business"],
                note: "...I will keep work trips tight and holidays loose"
            ),
            slider(
                "budget", "Budget comfort", status: .complete,
                ProfileV3SliderField(
                    value: 1, range: 0...2, style: .labels(["Value", "Balanced", "Premium"]),
                    format: .levels(["Value", "Balanced", "Premium"])
                ),
                note: "...I will balance price against comfort this way"
            ),
            chips(
                "languages", "Languages", status: .pending,
                options: [], selected: ["English", "Hindi"],
                picker: ProfileV3OptionPicker(
                    title: "+Add languages",
                    catalogue: [
                        "English", "Hindi", "Tamil", "French", "Spanish", "German", "Arabic", "Japanese", "Mandarin"
                    ].map { option($0) }
                ),
                note: "...I will pick guides and support in these languages"
            )
        ]
    )

    static let airportLogistics = ProfileV3AgentForm(
        agentID: ProfileV3AgentID.airportLogistics.rawValue,
        agentTag: "Airport logistics",
        foundCount: 3,
        totalCount: 4,
        noun: "airport logistics",
        summary: pulledTogetherSummary,
        sources: sources,
        sections: [
            ProfileV3FormSection(
                id: "car_pickup",
                title: "Pick your ride",
                status: .complete,
                control: .cars(
                    ProfileV3CarField(
                        options: cars,
                        selection: "tesla_cybertruck",
                        detail: ProfileV3Directive(go: "ride_picker", agentType: ProfileV3AgentID.airportLogistics.apiValue)
                    )
                ),
                note: ProfileV3FormNote(
                    text: "Book your ride on the app. Available in selected regions",
                    link: ProfileV3FormNote.Link(text: "selected regions", directive: ProfileV3Directive(go: "ride_regions"))
                )
            ),
            chips(
                "pickup_type", "Pick up type", status: .pending,
                options: ["Public", "Shared", "Private", "Cheapest"],
                allowsMultiple: false,
                note: "...I will scan flights 24x7 and get you the best deals"
            ),
            ProfileV3FormSection(
                id: "baggage",
                title: "Preferred baggage",
                status: .complete,
                control: .baggage(
                    ProfileV3BaggageField(tabs: [
                        ProfileV3BaggageTab(
                            id: "baggage_short_trips",
                            title: "Short trips (up to 7 days)",
                            items: bags,
                            quantities: ["cabin_bag": 1, "checkin_large": 1, "checkin_medium": 1, "baby_pram": 1],
                            isFound: true
                        ),
                        ProfileV3BaggageTab(
                            id: "baggage_long_trips",
                            title: "Long trips",
                            items: bags,
                            quantities: ["checkin_large": 2]
                        )
                    ])
                ),
                note: ProfileV3FormNote(text: "Baggage details help plan airport pickups, transfers and intercity travel")
            ),
            customRulesSection([])
        ]
    )

    private static let cars: [ProfileV3CarOption] = [
        car("tesla_cybertruck", "Tesla Cybertruck"),
        car("ferrari_296_gtb", "Ferrari 296 GTB"),
        car("porsche_911_gt3", "Porsche 911 GT3"),
        car("koenigsegg_jesko", "Koenigsegg Jesko"),
        car("ford_mustang", "Ford Mustang")
    ]

    static let rideRegions = ProfileV3RideRegions(
        title: "Pick your ride",
        heading: "Skip the queue not the ride",
        dividerLabel: "Now available in",
        regions: [
            ProfileV3RideRegions.Region(
                id: "0-AE",
                name: "Dubai",
                imageURL: URL(string: "https://media.atlys.com/b2c/ai-native/cars/regions/dubai.png"),
                aspectRatio: 1.819
            )
        ]
    )

    static let ridePicker = ProfileV3RidePicker(
        title: "Select your airport pickup",
        subtitle: "Bypass standard taxi queues with an on-demand exotic transfer waiting at arrival",
        note: "Available only in eligible regions",
        fieldKey: "car_pickup",
        options: cars.map { car in
            ProfileV3RideOption(
                id: car.id,
                name: car.name,
                brand: car.name.split(separator: " ").first.map(String.init),
                spec: "Dual motor, all-wheel drive",
                imageURL: ProfileV3CarArt.stage(car.id),
                isSelected: car.id == "tesla_cybertruck"
            )
        },
        footer: "Included with membership. Switch models anytime in Settings",
        regions: ["AE"]
    )

    private static let bags: [ProfileV3BaggageItem] = [
        bag("backpack", "Bag pack"),
        bag("hand_bag", "Hand bag"),
        bag("cabin_bag", "Cabin bag", isCountable: true),
        bag("checkin_large", "Check-in luggage", detail: "large", isCountable: true),
        bag("checkin_medium", "Check-in luggage", detail: "medium", isCountable: true),
        bag("baby_pram", "Baby pram"),
        bag("wheelchair", "Personal wheel chair"),
        bag("musical_instrument", "Musical instrument")
    ]

    static var airportCars: ProfileV3CarField {
        ProfileV3CarField(options: cars, selection: "tesla_cybertruck")
    }

    private static func car(_ id: String, _ name: String) -> ProfileV3CarOption {
        ProfileV3CarOption(
            id: id,
            name: name,
            imageURL: URL(string: "https://media.atlys.com/b2c/ai-native/cars/side/\(id).png"),
            stageImageURL: ProfileV3CarArt.stage(id)
        )
    }

    private static func bag(
        _ id: String,
        _ title: String,
        detail: String? = nil,
        isCountable: Bool = false
    ) -> ProfileV3BaggageItem {
        ProfileV3BaggageItem(
            id: id,
            title: title,
            detail: detail,
            imageURL: URL(string: "https://media.atlys.com/b2c/ai-native/cars/bags/\(id).png"),
            isCountable: isCountable
        )
    }

    private static let pulledTogetherSummary = "I\u{2019}ve pulled together what matters, "
        + "so you don\u{2019}t have to piece it all together yourself."

    private static func option(_ title: String) -> ProfileV3ChipOption {
        ProfileV3ChipOption(id: slug(title), title: title)
    }

    private static func slug(_ title: String) -> String {
        title.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: "-", options: .regularExpression)
    }

    private static func passport(
        _ id: String,
        _ title: String,
        passport: ProfileV3Passport?,
        previous: ProfileV3PassportPrevious?
    ) -> ProfileV3FormSection {
        let field = ProfileV3PassportField(
            holderName: passport?.holderName ?? "alex r.",
            countryName: passport?.countryName ?? ProfileV3Strings.passportCountryIndia,
            countryNativeName: passport?.countryNativeName ?? ProfileV3Strings.passportCountryIndiaNative,
            passport: passport,
            previous: previous,
            rescan: ProfileV3PassportFixtures.rescan,
            howUsed: ProfileV3PassportFixtures.howUsedDirective
        )
        return ProfileV3FormSection(
            id: id,
            title: title,
            status: passport == nil ? .pending : .complete,
            control: .passport(field)
        )
    }

    private static func chips(
        _ id: String,
        _ title: String,
        status: ProfileV3FormSection.Status? = nil,
        options: [String],
        selected: [String] = [],
        allowsMultiple: Bool = true,
        picker: ProfileV3OptionPicker? = nil,
        note: String? = nil,
        noteIcon: ProfileV3FormNote.Icon = .agent,
        source: ProfileV3SectionSource? = nil
    ) -> ProfileV3FormSection {
        let field = ProfileV3ChipField(
            options: options.map { option($0) },
            selection: Set(selected.map(slug)),
            allowsMultiple: allowsMultiple,
            picker: picker
        )
        return ProfileV3FormSection(
            id: id, title: title, status: status, control: .chips(field),
            note: note.map { ProfileV3FormNote(text: $0, icon: noteIcon) },
            source: source
        )
    }

    static let gmailSourceIcon = URL(string: "https://media.atlys.com/b2c/ai-native/icons/kyc/gmail.png")
    static let emiratesSourceIcon = URL(string: "https://media.atlys.com/b2c/ai-native/loyalty/flights/emirates_skywards.png")

    static let airlineSources = ProfileV3PreferenceSources(
        title: "Your preferred airlines",
        steps: [
            ProfileV3SourceStep(
                id: 0,
                iconURL: gmailSourceIcon,
                title: "Connected Gmail",
                body: "Searched emails for \u{201C}flight booking\u{201D}, \u{201C}boarding pass\u{201D}, airline names"
            ),
            ProfileV3SourceStep(
                id: 1,
                iconURL: gmailSourceIcon,
                title: "Found 18 flights",
                body: "7 IndiGo, 5 Vistara, 3 Emirates",
                viewsEmails: true
            ),
            ProfileV3SourceStep(
                id: 2,
                iconURL: gmailSourceIcon,
                title: "What we noticed",
                body: "IndiGo preferred for domestic flights, even when other airlines were available "
                    + "at similar times.",
                viewsEmails: true
            )
        ]
    )

    private static func cards(
        _ id: String,
        _ title: String,
        status: ProfileV3FormSection.Status? = nil,
        options: [(String, String)],
        selected: [String],
        note: String? = nil
    ) -> ProfileV3FormSection {
        let field = ProfileV3CardField(
            options: options.map { ProfileV3CardOption(id: slug($0.0), code: $0.0, detail: $0.1) },
            selection: Set(selected.map(slug))
        )
        return ProfileV3FormSection(
            id: id, title: title, status: status, control: .cards(field), note: note.map { ProfileV3FormNote(text: $0) }
        )
    }

    private static func slider(
        _ id: String,
        _ title: String,
        status: ProfileV3FormSection.Status? = nil,
        _ field: ProfileV3SliderField,
        note: String? = nil,
        noteIcon: ProfileV3FormNote.Icon = .agent
    ) -> ProfileV3FormSection {
        ProfileV3FormSection(
            id: id, title: title, status: status, control: .slider(field),
            note: note.map { ProfileV3FormNote(text: $0, icon: noteIcon) }
        )
    }

    private static func text(
        _ id: String,
        _ title: String,
        status: ProfileV3FormSection.Status? = nil,
        _ field: ProfileV3TextFieldValue,
        note: String? = nil
    ) -> ProfileV3FormSection {
        ProfileV3FormSection(
            id: id, title: title, status: status, control: .text(field), note: note.map { ProfileV3FormNote(text: $0) }
        )
    }
}
#endif
