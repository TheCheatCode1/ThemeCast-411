import SwiftUI

struct ContentView: View {
    @StateObject private var vm = WeatherViewModel()

    var body: some View {
        WeatherView(vm: vm)
    }
}

#Preview {
    ContentView()
}
