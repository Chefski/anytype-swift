import UIKit
import AnytypeCore

extension UIImage {
    static let backArrow = createImage("backArrow")
    
    static let searchIcon = createImage("searchTextFieldIcon")
    
    static let ghost = createImage(ImageName.ghost)
}

extension UIImage {
    enum editor {
        enum BlockOption {
            static let addBelow = createImage("TextEditor/BlocksOption/add_below")
            static let delete = createImage("TextEditor/BlocksOption/delete")
            static let duplicate = createImage("TextEditor/BlocksOption/duplicate")
            static let moveTo = createImage("TextEditor/BlocksOption/move_to")
            static let turnInto = createImage("TextEditor/BlocksOption/turn_into_object")
        }

        static let bigGhost = createImage("TextEditor/bigGhost")
    }
    
    enum editorNavigation {
        static let more = createImage("TextEditor/More")
        static let home = createImage("TextEditor/home")
        static let search = createImage("TextEditor/search")
        static let backArrow = createImage("TextEditor/backArrow")
        static let forwardArrow = createImage("TextEditor/forwardArrow")
    }
    
    enum edititngToolbar {
        enum ChangeType {
            static let search = createImage("search")
        }

        static let addNew = createImage("EditingToolbar/add_new")
        static let style = createImage("EditingToolbar/style")
        static let move = createImage("EditingToolbar/move")
        static let mention = createImage("EditingToolbar/mention")
        static let actions = createImage("EditingToolbar/actions")
    }
    
    enum divider {
        static let dots = createImage("TextEditor/Divider/Dots")
    }
    
    enum blockLink {
        static let empty = createImage("TextEditor/Link/empty")
    }
    
    enum blockFile {
        static let noImage = createImage("no_image")
        
        enum empty {
            static let image = createImage("TextEditor/BlockFile/Empty/Image")
            static let video = createImage("TextEditor/BlockFile/Empty/Video")
            static let file = createImage("TextEditor/BlockFile/Empty/File")
            static let bookmark = createImage("TextEditor/BlockFile/Empty/Bookmark")
        }
        
        enum content {
            static let text = createImage("TextEditor/BlockFile/Content/Text")
            static let spreadsheet = createImage("TextEditor/BlockFile/Content/Spreadsheet")
            static let presentation = createImage("TextEditor/BlockFile/Content/Presentation")
            static let pdf = createImage("TextEditor/BlockFile/Content/PDF")
            static let image = createImage("TextEditor/BlockFile/Content/Image")
            static let audio = createImage("TextEditor/BlockFile/Content/Audio")
            static let video = createImage("TextEditor/BlockFile/Content/Video")
            static let archive = createImage("TextEditor/BlockFile/Content/Archive")
            static let other = createImage("TextEditor/BlockFile/Content/Other")
        }
    }
    
    enum ObjectIcon {
        static let checkbox = createImage("todo_checkbox")
        static let checkmark = createImage("todo_checkmark")
    }
    
    enum codeBlock {
        static let arrow = createImage("TextEditor/turn_into_arrow")
    }
    
    enum textAttributes {
        static let code = createImage("TextAttributes/code")
        static let url = createImage("TextAttributes/url")
        static let bold = createImage("TextAttributes/bold")
        static let italic = createImage("TextAttributes/italic")
        static let strikethrough = createImage("TextAttributes/strikethrough")
        static let alignLeft = createImage("TextAttributes/align_left")
        static let alignRight = createImage("TextAttributes/align_right")
        static let alignCenter = createImage("TextAttributes/align_center")
    }
    
    static func createImage(_ name: String) -> UIImage {
        guard let image = UIImage(named: name) else {
            anytypeAssertionFailure("No image named: \(name)")
            return UIImage()
        }
        
        return image
    }
}
