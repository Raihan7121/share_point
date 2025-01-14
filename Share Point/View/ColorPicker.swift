
import SwiftUI

// MARK: - Protocol for Delegate Pattern
protocol ColorPickerDelegate {
    func didPickColor(_ color: Color, colorName: String)
}

// MARK: - Color Picker View
struct ColorPickerView: View {
    var delegate: ColorPickerDelegate? // Delegate to notify MainView
    @Environment(\.dismiss) var dismiss // Environment to dismiss the sheet

    private let colors: [(Color, String)] = [
        (.red, "Red"),
        (.green, "Green"),
        (.blue, "Blue"),
        (.yellow, "Yellow"),
        (.orange, "Orange"),
        (.purple, "Purple"),
        (.pink, "Pink"),
        (.gray, "Gray")
    ]

    var body: some View {
        NavigationStack {
            VStack {
                Text("Pick a Color")
                    .font(.headline)
                    .padding(5)
                    .foregroundColor(.red)

                // Grid of color options
                ForEach(colors, id: \.0) { color, name in
                    Button(action: {
                        delegate?.didPickColor(color, colorName: name) // Pass both color and name
                        dismiss() // Dismiss the sheet
                    }) {
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                            .padding(5)
                    }
                }
                .padding()
            }
        }
    }
}



