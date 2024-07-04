import SwiftUI


struct ColorPickerView: View {
    @StateObject var viewModel: TodoItemViewModel
    @State var dragOffset: CGPoint = .zero
    @State var brightness: Double = 0.5
    
    let colors: [Color] = {
        let hueValues = Array(0...359)
        return hueValues.map {
            Color(UIColor(hue: CGFloat($0) / 359.0 ,
                          saturation: 1.0,
                          brightness: 1.0,
                          alpha: 1.0))
        }
    }()

    private func currentColor(from location: CGPoint) {
        let x = max(0, min(location.x, UIScreen.main.bounds.width))
        let percent = x / UIScreen.main.bounds.width
        viewModel.color = Color(hue: Double(percent), saturation: 1.0, brightness: brightness)
        dragOffset = location
    }
    
    var body: some View {
        VStack(alignment: .center) {
            LinearGradient(gradient: Gradient(colors: colors),
                           startPoint: .leading,
                           endPoint: .trailing)
                .frame(height: 30)
                .cornerRadius(5)
                .shadow(radius: 8)
                .gesture(
                    DragGesture()
                        .onChanged({ (value) in
                            self.dragOffset = value.startLocation
                            self.currentColor(from: value.location)
                        })
                        .onEnded({ (value) in
                            self.currentColor(from: value.location)
                        })
            )
            Slider(value: Binding<Double>(
              get: { brightness },
              set: { newValue in
                brightness = newValue
                  self.currentColor(from: self.dragOffset)
              }
            ), in: 0...1, step: 0.01)
        }
    }
}
