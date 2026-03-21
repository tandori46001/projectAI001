import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: DataStore

    var body: some View {
        if store.catalogIsEmpty {
            WizardView()
        } else {
            MainView()
        }
    }
}
