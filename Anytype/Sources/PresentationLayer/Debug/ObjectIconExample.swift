import SwiftUI

struct ObjectIconExample: View {
    
    private let emojiExamples: [CGFloat] = [16, 18, 40, 48, 64, 80, 96]

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: "Icons")
            ScrollView {
                VStack(spacing: 20) {
                    AnytypeText("Emoji", style: .subheading, color: .Text.primary)
                    emoji()
                }
            }
        }
    }
    
    @ViewBuilder
    private func emoji() -> some View {
        ForEach(0..<emojiExamples.count, id: \.self) { index in
            let size = emojiExamples[index]
            AnytypeText("Size \(size)", style: .bodyRegular, color: .Text.primary)
            HStack(spacing: 0) {
                HStack {
                    Spacer()
                    EmojiIconView(text: "😀")
                        .frame(width: size, height: size)
                    Spacer()
                }
                .padding(10)
                .background(Color.white)
                .colorScheme(.light)
                HStack {
                    Spacer()
                    EmojiIconView(text: "😀")
                        .frame(width: size, height: size)
                    Spacer()
                }
                .padding(10)
                .background(Color.black)
                .colorScheme(.dark)
            }
            .padding(.bottom, 10)
            .newDivider()
        }
    }
}

struct ObjectIconExample_Previews: PreviewProvider {
    static var previews: some View {
        ColorsExample()
    }
}
