import UIKit

class MenuViewController: UIViewController {
    static let TWCOpenChannelSegue = "OpenChat"
    static let TWCRefreshControlXOffset: CGFloat = 120
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bgImage = UIImageView(image: UIImage(named:"home-bg"))
        bgImage.frame = self.tableView.frame
        tableView.backgroundView = bgImage
        
        usernameLabel.text = MessagingManager.sharedManager().userIdentity
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(MenuViewController.refreshChannels), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        
        self.refreshControl.frame.origin.x -= MenuViewController.TWCRefreshControlXOffset
        ChannelManager.sharedManager.delegate = self
        tableView.reloadData()
    }
    
    // MARK: - Internal methods
    
    func loadingCellForTableView(tableView: UITableView) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "loadingCell")!
    }
    
    func channelCellForTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let menuCell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath as IndexPath) as! MenuTableCell
        
        if let channelDescriptor = ChannelManager.sharedManager.channelDescriptors![indexPath.row] as? TCHChannelDescriptor {
            menuCell.channelName = channelDescriptor.friendlyName ?? "[Unknown channel name]"
        } else {
            menuCell.channelName = "[Unknown channel name]"
        }
        
        return menuCell
    }
    
    @objc func refreshChannels() {
        refreshControl.beginRefreshing()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func deselectSelectedChannel() {
        let selectedRow = tableView.indexPathForSelectedRow
        if let row = selectedRow {
            tableView.deselectRow(at: row, animated: true)
        }
    }
    
    // MARK: - Channel
    
    func createNewChannelDialog() {
        InputDialogController.showWithTitle(title: "New Channel",
                                            message: "Enter a name for this channel",
                                            placeholder: "Name",
                                            presenter: self) { text in
                                                ChannelManager.sharedManager.createChannelWithName(name: text, completion: { _,_ in
                                                    ChannelManager.sharedManager.populateChannelDescriptors()
                                                })
        }
    }
    
    // MARK: Logout
    
    func promptLogout() {
        let alert = UIAlertController(title: nil, message: "You are about to Logout", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { action in
            self.logOut()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    func logOut() {
        MessagingManager.sharedManager().logout()
        MessagingManager.sharedManager().presentRootViewController()
    }
    
    // MARK: - Actions
    
    @IBAction func logoutButtonTouched(_ sender: UIButton) {
        promptLogout()
    }
    
    @IBAction func newChannelButtonTouched(_ sender: UIButton) {
        createNewChannelDialog()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == MenuViewController.TWCOpenChannelSegue {
            let indexPath = sender as! NSIndexPath
            
            let channelDescriptor = ChannelManager.sharedManager.channelDescriptors![indexPath.row] as! TCHChannelDescriptor
            let navigationController = segue.destination as! UINavigationController
            
            channelDescriptor.channel { (result, channel) in
                if let channel = channel {
                    (navigationController.visibleViewController as! MainChatViewController).channel = channel
               }
            }
            
        }
    }
    
    // MARK: - Style
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - UITableViewDataSource
extension MenuViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let channelDescriptors = ChannelManager.sharedManager.channelDescriptors {
            print (channelDescriptors.count)
            return channelDescriptors.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if ChannelManager.sharedManager.channelDescriptors == nil {
            cell = loadingCellForTableView(tableView: tableView)
        }
        else {
            cell = channelCellForTableView(tableView: tableView, atIndexPath: indexPath as NSIndexPath)
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let channel = ChannelManager.sharedManager.channelDescriptors?.object(at: indexPath.row) as? TCHChannel {
            return channel != ChannelManager.sharedManager.generalChannel
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle != .delete {
            return
        }
        if let channel = ChannelManager.sharedManager.channelDescriptors?.object(at: indexPath.row) as? TCHChannel {
            channel.destroy { result in
                if (result.isSuccessful()) {
                    tableView.reloadData()
                }
                else {
                    AlertDialogController.showAlertWithMessage(message: "You can not delete this channel", title: nil, presenter: self)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension MenuViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: MenuViewController.TWCOpenChannelSegue, sender: indexPath)
    }
}


// MARK: - ChannelManagerDelegate
extension MenuViewController : ChannelManagerDelegate {
    func reloadChannelDescriptorList() {
        tableView.reloadData()
    }
}
