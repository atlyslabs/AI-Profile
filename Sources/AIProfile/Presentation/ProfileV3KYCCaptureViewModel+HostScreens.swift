import Foundation

extension ProfileV3KYCCaptureViewModel {
    var travellerID: String? {
        capture.route == .coTraveller ? capture.profileID : nil
    }

    func gmailScreen(_ gmail: Gmail) -> ProfileV3KYC.GmailConnectScreen {
        ProfileV3KYC.GmailConnectScreen(
            content: gmail.step.connectorContent,
            connectCTA: gmail.step.connectCTA,
            userImageURL: gmail.step.userImageURL,
            brandIcons: gmail.step.icons,
            progress: progress,
            isConnecting: gmail.isConnecting,
            nextStepReady: gmail.nextStepReady
        )
    }

    var gmailActions: ProfileV3KYC.GmailConnectActions {
        ProfileV3KYC.GmailConnectActions(
            connect: connectGmail,
            switchToManual: leave,
            convergenceFinished: gmailConvergenceFinished,
            back: leave
        )
    }

    func itrScreen(_ itr: ITR) -> ProfileV3KYC.ITRConnectScreen {
        ProfileV3KYC.ITRConnectScreen(
            content: itr.step.connectorContent,
            skippable: itr.step.skippable,
            skipCTA: itr.step.skipCTA,
            findings: itr.step.findings,
            progress: progress,
            isBusy: itr.isBusy
        )
    }

    var itrActions: ProfileV3KYC.ITRConnectActions {
        ProfileV3KYC.ITRConnectActions(
            uploadPDF: uploadITR,
            connect: connectITR(pan:password:),
            skip: skipITR,
            done: finishITR,
            back: leave
        )
    }

    func passportScreen(
        stepID: String?,
        front: ProfileV3CaptureCopy?,
        back: ProfileV3CaptureCopy?
    ) -> ProfileV3KYC.PassportCaptureScreen {
        ProfileV3KYC.PassportCaptureScreen(
            stepID: stepID ?? capture.profileID,
            front: front,
            back: back,
            progress: progress,
            travellerID: travellerID
        )
    }

    var passportActions: ProfileV3KYC.PassportCaptureActions {
        ProfileV3KYC.PassportCaptureActions(
            upload: passportUploader.upload(_:jpeg:residenceCountryCode:),
            completed: passportCompleted,
            cancel: leave
        )
    }

    func selfieScreen(copy: ProfileV3CaptureCopy?) -> ProfileV3KYC.SelfieCaptureScreen {
        ProfileV3KYC.SelfieCaptureScreen(copy: copy, progress: progress, travellerID: travellerID)
    }

    var selfieActions: ProfileV3KYC.SelfieCaptureActions {
        ProfileV3KYC.SelfieCaptureActions(upload: uploadSelfie, completed: selfieCompleted, cancel: leave)
    }
}

private extension ProfileV3CaptureStep {
    var connectorContent: ProfileV3KYC.ConnectorContent {
        ProfileV3KYC.ConnectorContent(
            state: connectorState ?? .idle,
            pollAfterMilliseconds: pollAfterMilliseconds,
            errorMessage: errorMessage,
            title: title,
            cardTitle: cardTitle,
            cardSubtitle: cardSubtitle,
            lookingFor: lookingFor
        )
    }
}
