import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Product.sortOrder) private var products: [Product]

    @State private var showWizard = false
    @State private var hasCheckedSetup = false

    var body: some View {
        Group {
            if hasCheckedSetup {
                MainView()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if !hasCheckedSetup {
                showWizard = products.isEmpty
                hasCheckedSetup = true
            }
        }
        .fullScreenCover(isPresented: $showWizard) {
            WizardView {
                showWizard = false
            }
        }
    }
}
