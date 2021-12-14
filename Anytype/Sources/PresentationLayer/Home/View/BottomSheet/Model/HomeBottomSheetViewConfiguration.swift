import CoreGraphics

extension HomeBottomSheetView {
    // Offsets counts from the top of the screen
    struct Configuration {
        let cornerRadius: CGFloat = 16
        let containerHeight: CGFloat

        var maxHeight: CGFloat { containerHeight * heightRatio }
        var snapOffset: CGFloat { closedOffset - snapHeight }
        var maxOffset: CGFloat { containerHeight * maxOffsetRatio }
        var openOffset: CGFloat { containerHeight * (1 - heightRatio) }
        var closedOffset: CGFloat { sheetHeight + openOffset }

        func validatedOffset(_ offset: CGFloat, isOpen: Bool) -> CGFloat {
            let defaultOffset = isOpen ? openOffset : closedOffset
            let validatedTopEdgeOffset = max(defaultOffset + offset, openOffset)
            
            return min(maxOffset, validatedTopEdgeOffset)
        }
        
        private var minHeight: CGFloat { maxHeight * minHeightRatio }
        private var sheetHeight: CGFloat { maxHeight - minHeight }
        private var snapHeight: CGFloat { maxHeight * snapRatio }

        private let snapRatio: CGFloat = 0.05
        private let heightRatio: CGFloat = 0.89 // under settings button
        private let minHeightRatio: CGFloat = 0.55
        private let maxOffsetRatio: CGFloat = 0.9
    }
}