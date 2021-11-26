public enum Feature: String, Codable {
    case sets = "Sets YEAH 🚀"
    case rainbowCells = "Paint editor cells 🌈"
    case showAlertOnAssert = "Show alerts on asserts\n(only in testflight dev)"
    case analytics = "Analytics Amplitude (only in development)"
    case middlewareLogs = "Show middleware logs in Xcode console"
    case relationsEditing = "Is relations editing available?"
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
        .sets: !isRelease,
        .rainbowCells: false,
        .showAlertOnAssert : true,
        .analytics : false,
        .middlewareLogs: false,
        .relationsEditing: !isRelease
    ]
    
    public static func update(key: Feature, value: Bool) {
        var updatedFeatures = FeatureFlagsStorage.featureFlags
        updatedFeatures.updateValue(value, forKey: key)
        FeatureFlagsStorage.featureFlags = updatedFeatures
    }
}

public extension FeatureFlags {
    static var sets: Bool {
        features[.sets, default: false]
    }
    
    static var showAlertOnAssert: Bool {
        features[.showAlertOnAssert, default: true]
    }

    static var analytics: Bool {
        features[.analytics, default: false]
    }
    
    static var rainbowCells: Bool {
        features[.rainbowCells, default: false]
    }
    
    static var middlewareLogs: Bool {
        features[.middlewareLogs, default: false]
    }
    
    static var relationsEditing: Bool {
        features[.relationsEditing, default: false]
    }
}
