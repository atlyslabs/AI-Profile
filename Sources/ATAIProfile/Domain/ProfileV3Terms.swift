import Foundation

struct ProfileV3TermsBlock: Identifiable, Equatable {
    let id: String
    var heading: String?
    let paragraphs: [String]
}

struct ProfileV3TermsSection: Identifiable, Equatable {
    let id: String
    let title: String
    let blocks: [ProfileV3TermsBlock]
}

struct ProfileV3Terms: Equatable {
    let title: String
    let sections: [ProfileV3TermsSection]
}
