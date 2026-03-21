import SwiftUI

struct ContentView: View {
    @Environment(DataStore.self) private var store

    var body: some View {
        if store.catalog.isEmpty {
            WizardView()
        } else {
            MainView()
        }
    }
}
