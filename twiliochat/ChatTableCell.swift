import UIKit

class ChatTableCell: UITableViewCell {
    static let TWCUserLabelTag = 200
    static let TWCDateLabelTag = 201
    static let TWCMessageLabelTag = 202
	static let TWCMediaViewTag = 203
    
    var userLabel: UILabel!
    var messageLabel: UILabel!
    var dateLabel: UILabel!
	var mediaView: UIImageView!
	
	let uniqueCellID = UUID()
	
	// Deneme amaçlı - yeri doğru değil
	var imageCache = NSCache<NSString, UIImage>()
    
	func setUser(user:String!, message:String!, date:String!, image: UIImage? = nil) {
        userLabel.text = user
        messageLabel.text = message
        dateLabel.text = date
		// if let data = data { mediaView.image = UIImage(data: data) }
		if let image = image {
			if let cachedImage = imageCache.object(forKey: uniqueCellID.uuidString as NSString) {
				mediaView.image = cachedImage
			} else {
				mediaView.image = image
				imageCache.setObject(image, forKey: uniqueCellID.uuidString as NSString)
			}
			
			mediaView.isHidden = false
		} else {
			mediaView.isHidden = true
		}
    }
    
    override func awakeFromNib() {
        userLabel = viewWithTag(ChatTableCell.TWCUserLabelTag) as? UILabel
        messageLabel = viewWithTag(ChatTableCell.TWCMessageLabelTag) as? UILabel
        dateLabel = viewWithTag(ChatTableCell.TWCDateLabelTag) as? UILabel
		mediaView = viewWithTag(ChatTableCell.TWCMediaViewTag) as? UIImageView
    }
}


// MARK: - UIImageViewExtension for chat media images
extension UIImageView {
	
	
	
}
