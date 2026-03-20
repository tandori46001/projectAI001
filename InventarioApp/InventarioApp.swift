import SwiftUI
import SwiftData

@main
struct InventarioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Product.self,
            InventoryTable.self,
            Jornada.self,
            JornadaEntry.self
        ])
    }
}
