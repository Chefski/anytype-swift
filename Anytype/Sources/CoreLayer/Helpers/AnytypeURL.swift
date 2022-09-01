import Foundation

struct AnytypeURL {
    
    private let sourceString: String
    private let sourceURL: URL
    
    init?(string: String) {
        
        // Example :
        //     Input string incorrect for url, but contains encoded symbols:
        //     https://www.figma.com/file/zXl9RNoINX07RXg2qZtfKP/Mobile-–-WebClipper-%26-Bookmarks?node-id=12395%3A1153
        //     Remove encoding:
        //     https://www.figma.com/file/zXl9RNoINX07RXg2qZtfKP/Mobile-–-WebClipper-&-Bookmarks?node-id=12395:1153
        //     Add percent encoding. Corrent for URL:
        //     https://www.figma.com/file/zXl9RNoINX07RXg2qZtfKP/Mobile-%E2%80%93-WebClipper-&-Bookmarks?node-id=12395:1153

        let removingPercent = string.removingPercentEncoding ?? string
        let encodedString = removingPercent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let encodedString = encodedString,
              let url = URL(string: encodedString) else { return nil }
        
        self.sourceString = string
        self.sourceURL = url
    }
    
    init(url: URL) {
        self.sourceURL = url
        self.sourceString = url.absoluteString.removingPercentEncoding ?? url.absoluteString
    }
    
    var absoluteString: String {
        return sourceString
    }
    
    var url: URL {
        return sourceURL
    }
}
