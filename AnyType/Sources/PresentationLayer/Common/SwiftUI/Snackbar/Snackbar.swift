import SwiftUI

// https://github.com/Zi0P4tch0/Swift-UI-Views
struct Snackbar: View {

    @Binding var isShowing: Bool
    private let presenting: AnyView
    private let text: Text
    private let actionText: Text?
    private let action: (() -> Void)?

    private var isBeingDismissedByAction: Bool {
        actionText != nil && action != nil
    }

    init<Presenting>(isShowing: Binding<Bool>,
         presenting: Presenting,
         text: Text,
         actionText: Text? = nil,
         action: (() -> Void)? = nil) where Presenting: View {

        _isShowing = isShowing
        self.presenting = AnyView(presenting)
        self.text = text
        self.actionText = actionText
        self.action = action

    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.presenting
                VStack {
                    Spacer()
                    if self.isShowing {
                        HStack {
                            Image.checked
                            self.text
                                .foregroundColor(Color.textPrimary)
                            Spacer()
                            if (self.actionText != nil && self.action != nil) {
                                self.actionText!
                                    .bold()
                                    .foregroundColor(Color.textPrimary)
                                    .onTapGesture {
                                        self.action?()
                                        withAnimation {
                                            self.isShowing = false
                                        }
                                    }
                            }
                        }
                        .padding()
                        .frame(width: geometry.size.width * 0.9, height: 64)
                        .background(Color.background)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 7)
                        .offset(x: 0, y: -20)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom),
                                removal: .opacity
                            )
                        )
                        .animation(Animation.spring())
                        .onAppear {
                            guard !self.isBeingDismissedByAction else { return }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    self.isShowing = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}
