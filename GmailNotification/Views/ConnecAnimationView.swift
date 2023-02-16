import SwiftUI

struct ConnecAnimationView: View {
    @State private var isRotating = 0.0
    var theme: Int
    
    var body: some View {
        Image(systemName: "circle.hexagonpath")
            .background(theme == 1 ? .gray : .white)
            .clipShape(Circle())
            .font(.system(size: 15))
            .rotationEffect(.degrees(isRotating))
            .onAppear {
                withAnimation(.linear(duration: 1)
                    .speed(0.2).repeatForever(autoreverses: false)) {
                        isRotating = 360.0
                    }
            }
    }
}
