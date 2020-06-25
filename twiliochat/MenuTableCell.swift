import UIKit

class MenuTableCell: UITableViewCell {
    var label: UILabel!
    
    var channelName: String {
        get {
            return label?.text ?? String()
        }
        set(name) {
            label.text = name
        }
    }
    
    var selectedBackgroundColor: UIColor {
        return UIColor(red:0.969, green:0.902, blue:0.894, alpha:1)
    }
    
    var labelHighlightedTextColor: UIColor {
        return UIColor(red:0.22, green:0.024, blue:0.016, alpha:1)
    }
    
    var labelTextColor: UIColor {
        return UIColor(red:0.973, green:0.557, blue:0.502, alpha:1)
    }
    
    override func awakeFromNib() {
        label = viewWithTag(200) as? UILabel
        label.highlightedTextColor = labelHighlightedTextColor
        label.textColor = labelTextColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            contentView.backgroundColor = selectedBackgroundColor
        } else {
            contentView.backgroundColor = nil
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if (highlighted) {
            contentView.backgroundColor = selectedBackgroundColor
        } else {
            contentView.backgroundColor = nil
        }
    }
}
