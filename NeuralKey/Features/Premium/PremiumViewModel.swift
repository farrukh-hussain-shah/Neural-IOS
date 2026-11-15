import Observation

@MainActor
@Observable
final class PremiumViewModel {
    private(set) var selectedPlan: PremiumPlan

    init(selectedPlan: PremiumPlan = .defaultSelection) {
        self.selectedPlan = selectedPlan
    }

    func select(_ plan: PremiumPlan) {
        selectedPlan = plan
    }
}
