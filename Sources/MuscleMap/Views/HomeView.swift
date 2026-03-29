import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        TabView {
            BodyMapView()
                .tabItem { Label("Body", systemImage: "figure.arms.open") }
                .environment(\.managedObjectContext, context)

            LogView()
                .tabItem { Label("Log", systemImage: "list.bullet.clipboard") }
                .environment(\.managedObjectContext, context)
        }
    }
}
