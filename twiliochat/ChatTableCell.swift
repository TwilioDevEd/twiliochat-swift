import UIKit

class ChatTableCell: UITableViewCell {
    static let TWCUserLabelTag = 200
    static let TWCDateLabelTag = 201
    static let TWCMessageLabelTag = 202
    
    var userLabel: UILabel!
    var messageLabel: UILabel!
    var dateLabel: UILabel!
    
    func setUser(user:String!, message:String!, date:String!) {
        userLabel.text = user
        messageLabel.text = message
        dateLabel.text = date
    }
    
    override func awakeFromNib() {
        userLabel = viewWithTag(ChatTableCell.TWCUserLabelTag) as? UILabel
        messageLabel = viewWithTag(ChatTableCell.TWCMessageLabelTag) as? UILabel
        dateLabel = viewWithTag(ChatTableCell.TWCDateLabelTag) as? UILabel
    }
}
