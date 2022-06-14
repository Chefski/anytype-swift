public enum Feature: String, Codable {
    case rainbowViews = "Paint editor views 🌈"
    case showAlertOnAssert = "Show alerts on asserts\n(only in testflight dev)"
    case analytics = "Analytics Amplitude (only in development)"
    case middlewareLogs = "Show middleware logs in Xcode console"

    case uikitRelationBlocks = "UIKit relation blocks"
    case clipboard = "Clipboard"
    case objectPreview = "Object preview"
    case deletion = "Account deletion"
    case createNewRelation = "Create new relation"
    case templates = "Show templates picker"
    case createObjectInSet = "Create object in Set"
    case floatingSetMenu = "Floating Set menu"
}

public final class FeatureFlags {
    public typealias Features = [Feature: Bool]
    
    public static var features: Features {
        FeatureFlagsStorage.featureFlags.merging(defaultValues, uniquingKeysWith: { (first, _) in first })
    }
    
    private static var isRelease: Bool {
        #if RELEASE
        true
        #else
        false
        #endif
    }
    
    private static let defaultValues: Features = [
        .rainbowViews: false,
        .showAlertOnAssert : true,
        .analytics : false,
        .middlewareLogs: false,
        .clipboard: true,
        .uikitRelationBlocks: true,
        .objectPreview: true,
        .deletion: false,
        .createNewRelation: true,
        .templates: true,
        .createObjectInSet: true,
        .floatingSetMenu: false
    ]
    
    public static func update(key: Feature, value: Bool) {
        var updatedFeatures = FeatureFlagsStorage.featureFlags
        updatedFeatures.updateValue(value, forKey: key)
        FeatureFlagsStorage.featureFlags = updatedFeatures
    }
}

public extension FeatureFlags {

    static var showAlertOnAssert: Bool {
        features[.showAlertOnAssert, default: true]
    }

    static var analytics: Bool {
        features[.analytics, default: false]
    }
    
    static var rainbowViews: Bool {
        features[.rainbowViews, default: false]
    }
    
    static var middlewareLogs: Bool {
        features[.middlewareLogs, default: false]
    }

    static var uikitRelationBlock: Bool {
        features[.uikitRelationBlocks, default: true]
    }

    static var clipboard: Bool {
        features[.clipboard, default: true]
    }

    static var objectPreview: Bool {
        features[.objectPreview, default: true]
    }
    
    static var deletion: Bool {
        features[.deletion, default: false]
    }
    
    static var createNewRelation: Bool {
        features[.createNewRelation, default: true]
    }

    static var isTemplatesAvailable: Bool {
        features[.templates, default: true]
    }

    static var isCreateObjectInSetAvailable: Bool {
        features[.createObjectInSet, default: true]
    }
    
    static var isFloatingSetMenuAvailable: Bool {
        features[.floatingSetMenu, default: false]
    }
}
