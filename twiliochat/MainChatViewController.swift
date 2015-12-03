import UIKit
import SWRevealViewController

class MainChatViewController: UIViewController {
    @IBOutlet weak var revealButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        if (revealViewController() != nil) {
            revealButtonItem.target = revealViewController()
            revealButtonItem.action = "revealToggle:"
            navigationController?.navigationBar.addGestureRecognizer(revealViewController().panGestureRecognizer())
            revealViewController().rearViewRevealOverdraw = 0
        }
    }

}
