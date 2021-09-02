import UIKit

// MARK: - LayoutStrategy + ScrollableStack

public extension UIView {

    struct Stack {}
    
    struct ScrollableStackConfiguration {
        let alwaysBounceVertical: Bool
        let showIndicators: Bool
        let axis: Axis
        
        public init(alwaysBounceVertical: Bool = false,
                    showIndicators: Bool = false,
                    axis: Axis = .vertical) {
            self.alwaysBounceVertical = alwaysBounceVertical
            self.showIndicators = showIndicators
            self.axis = axis
        }
    }
    
    enum Axis {
        case vertical
        case horizontal
        case mixed
    }
    
    // swiftlint:disable function_body_length
    /// UIScrollView with embedded stack layout strategy.
    /// - Parameters:
    ///   - scrollViewLayout: Position ScrollView as needed, otherwise pinned to rootView
    ///   - stackViewLayout: Position StackView as needed, otherwise pinned to scrollView.
    ///    If this parameter is present then stack container view is laid out as greater than or equal to scroll view size
    ///   - config: Scrollable stack configuration
    ///   - builder: Place arranged subviews here
    @discardableResult
    func scrollableStack(scrollViewLayout: ((UIScrollView) -> Void)? = nil,
                         stackViewLayout: ((UIStackView) -> Void)? = nil,
                         config: ScrollableStackConfiguration = ScrollableStackConfiguration(),
                         builder: ((Stack) -> UIStackView)) -> UIScrollView {
        let scrollView = UIScrollView()
        addSubview(scrollView)
        scrollView.alwaysBounceVertical = config.alwaysBounceVertical
        scrollView.showsVerticalScrollIndicator = config.showIndicators
        scrollView.showsHorizontalScrollIndicator = config.showIndicators
        
        if let scrollViewLayout = scrollViewLayout {
            scrollViewLayout(scrollView)
        } else {
            scrollView.pinAllEdges(to: self)
        }
        
        let contentView = UIView()
        contentView.layoutUsing.stack(layout: stackViewLayout, builder: builder)
        
        scrollView.addSubview(contentView)
        contentView.layoutUsing.anchors {
            $0.pinToSuperview()
            switch config.axis {
            case .vertical:
                $0.width.equal(to: scrollView.widthAnchor)
                if stackViewLayout.isNotNil {
                    $0.height.greaterThanOrEqual(to: scrollView.heightAnchor)
                }
            case .horizontal:
                $0.height.equal(to: scrollView.heightAnchor)
                if stackViewLayout.isNotNil {
                    $0.width.greaterThanOrEqual(to: scrollView.widthAnchor)
                }
            case .mixed:
                break
            }
        }
        
        return scrollView
    }
    // swiftlint:enable function_body_length

}

// MARK: - Stack + hStack/vStack

public extension UIView.Stack {
    
    /// Horizontally aligned stack view
    ///
    /// - Parameters:
    ///   - alignedTo: Layout transverse to the stacking axis
    ///   - distributedTo: Layout of the arrangedSubviews along the axis
    ///   - views: views to place inside the stack
    /// - Returns: Ready stack view
    @discardableResult
    func hStack(alignedTo: UIStackView.Alignment = .fill,
                distributedTo: UIStackView.Distribution = .fill,
                _ views: UIView...) -> UIStackView {
        
        stack(axis: .horizontal,
              alignedTo: alignedTo,
              distributedTo: distributedTo,
              views)
    }
    
    /// Horizontally aligned stack view
    ///
    /// - Parameters:
    ///   - alignedTo: Layout transverse to the stacking axis
    ///   - distributedTo: Layout of the arrangedSubviews along the axis
    ///   - views: views to place inside the stack
    /// - Returns: Ready stack view
    @discardableResult
    func hStack(alignedTo: UIStackView.Alignment = .fill,
                distributedTo: UIStackView.Distribution = .fill,
                _ views: [UIView]) -> UIStackView {
        
        stack(axis: .horizontal,
              alignedTo: alignedTo,
              distributedTo: distributedTo,
              views)
    }
    
    /// Vertically aligned stack view
    ///
    /// - Parameters:
    ///   - alignedTo: Layout transverse to the stacking axis
    ///   - distributedTo: Layout of the arrangedSubviews along the axis
    ///   - views: views to place inside the stack
    /// - Returns: Ready stack view
    @discardableResult
    func vStack(alignedTo: UIStackView.Alignment = .fill,
                distributedTo: UIStackView.Distribution = .fill,
                _ views: UIView...) -> UIStackView {
        
        stack(axis: .vertical,
              alignedTo: alignedTo,
              distributedTo: distributedTo,
              views)
    }
    
    /// Vertically aligned stack view
    ///
    /// - Parameters:
    ///   - alignedTo: Layout transverse to the stacking axis
    ///   - distributedTo: Layout of the arrangedSubviews along the axis
    ///   - views: views to place inside the stack
    /// - Returns: Ready stack view
    @discardableResult
    func vStack(alignedTo: UIStackView.Alignment = .fill,
                distributedTo: UIStackView.Distribution = .fill,
                _ views: [UIView]) -> UIStackView {
        
        stack(axis: .vertical,
              alignedTo: alignedTo,
              distributedTo: distributedTo,
              views)
    }
    
    @discardableResult
    private func stack(axis: NSLayoutConstraint.Axis,
                       alignedTo: UIStackView.Alignment = .fill,
                       distributedTo: UIStackView.Distribution = .fill,
                       _ views: [UIView]) -> UIStackView {
        
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = axis
        stackView.alignment = alignedTo
        stackView.distribution = distributedTo
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
}

// MARK: - Stack + gaps

public extension UIView.Stack {
    
    /// Gap with min/max height
    ///
    /// - Parameters:
    ///   - min: min height of gap
    ///   - max: max height of gap
    ///   - color: color of gap
    ///   - relatedTo: view on which gap existence is dependent
    ///   - reversely: flag that manages gap appearance relation to view that it depends on.
    ///   If true - gap appears if view is hidden. If false - gap appears if view is visible. Default is false.
    /// - Returns: view representing the gap
    func vGap(min minHeight: CGFloat,
              max maxHeight: CGFloat? = nil,
              color: UIColor = .clear,
              relatedTo relatedView: UIView? = nil,
              reversely: Bool = false) -> UIView {
        let spacing = GapView(relatedView: relatedView, reversely: reversely)
        spacing.backgroundColor = color
        
        spacing.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight).isActive = true
        if let maxHeight = maxHeight {
            spacing.heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight).isActive = true
        }
        
        return spacing
    }
    
    /// Vertical gap between arranged subviews
    ///
    /// - Parameter height: height of gap
    /// - Returns: view representing the gap
    func vGap(fixed height: CGFloat) -> UIView {
        vGap(fixed: height, color: .clear)
    }
    
    /// Vertical gap between arranged subviews
    ///
    /// - Parameters:
    ///   - height: height of gap
    ///   - color: color of gap
    ///   - relatedTo: view on which gap existence is dependent
    ///   - reversely: flag that manages gap appearance relation to view that it depends on.
    ///   If true - gap appears if view is hidden. If false - gap appears if view is visible. Default is false.
    /// - Returns: view representing the gap
    func vGap(fixed height: CGFloat? = nil,
              color: UIColor = .clear,
              relatedTo relatedView: UIView? = nil,
              reversely: Bool = false) -> UIView {
        
        let spacing = GapView(relatedView: relatedView, reversely: reversely)
        spacing.backgroundColor = color
        
        if let height = height {
            spacing.heightAnchor.constraint(equalToConstant: height).isActive = true
        } else {
            spacing.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            spacing.setContentHuggingPriority(.defaultLow, for: .vertical)
        }

        return spacing
    }
    
    /// Horizontal gap between arranged subviews
    ///
    /// - Parameter width: width of gap
    /// - Returns: view representing the gap
    func hGap(fixed width: CGFloat) -> UIView {
        hGap(fixed: width, color: .clear)
    }
    
    /// Horizontal gap between arranged subviews
    ///
    /// - Parameters:
    ///   - width: width of gap
    ///   - color: color of gap
    ///   - relatedTo: view on which gap existence is dependent
    ///   - reversely: flag that manages gap appearance relation to view that it depends on.
    ///   If true - gap appears if view is hidden. If false - gap appears if view is visible. Default is false.
    /// - Returns: view representing the gap
    func hGap(fixed width: CGFloat? = nil,
              color: UIColor = .clear,
              relatedTo relatedView: UIView? = nil,
              reversely: Bool = false) -> UIView {
        
        let spacing = GapView(relatedView: relatedView, reversely: reversely)
        spacing.backgroundColor = color
        
        if let width = width {
            spacing.widthAnchor.constraint(equalToConstant: width).isActive = true
        } else {
            spacing.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            spacing.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
        
        return spacing
    }
    
    /// Horizontal gap between arranged subviews
    ///
    /// - Parameter width: width of gap
    /// - Returns: view representing the gap
    func hGap(min width: CGFloat) -> UIView {
        let spacing = UIView()
        spacing.widthAnchor.constraint(greaterThanOrEqualToConstant: width).isActive = true
        spacing.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        spacing.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return spacing
    }
    
}

private final class GapView: UIView {

    private var observation: NSKeyValueObservation?

    init(relatedView: UIView?, reversely: Bool) {
        super.init(frame: .zero)

        observation = relatedView?.observe(\.isHidden, options: [.new, .initial]) { [weak self] _, change in
            change.newValue.map {
                self?.isHidden = reversely ? !$0 : $0
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
