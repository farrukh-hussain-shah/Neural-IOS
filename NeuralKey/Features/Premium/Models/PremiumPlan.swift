import SwiftUI

enum PremiumPlan: String, CaseIterable, Identifiable {
    case weekly
    case monthly
    case yearly

    static let defaultSelection: PremiumPlan = .monthly

    var id: String { rawValue }
}

struct PremiumPlanOption: Identifiable {
    let plan: PremiumPlan
    let title: LocalizedStringKey
    let price: String
    let billingUnit: LocalizedStringKey
    let savings: String
    var badge: LocalizedStringKey?

    var id: PremiumPlan { plan }
}
