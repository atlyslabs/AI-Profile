import ATAIProfile

struct VDCProfileV3Session: ProfileV3SessionProviding {
    var currentUserID: String? {
        UserData.currentUser?.userUid
    }

    @MainActor var isGuestSession: Bool {
        GuestSession.firebaseResolver()
    }
}
