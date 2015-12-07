import UIKit
import Parse

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TwilioIPMessagingClientDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var refreshControl: UIRefreshControl!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bgImage = UIImageView(image: UIImage(named:"home-bg"))
        bgImage.frame = self.tableView.frame
        tableView.backgroundView = bgImage

        usernameLabel.text = IPMessagingManager.sharedManager.userIdentity
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "refreshChannels", forControlEvents: .ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        
        self.refreshControl.frame.origin.x = -120
        ChannelManager.sharedManager.delegate = self
        self.populateChannels()
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let channels = ChannelManager.sharedManager.channels {
            return channels.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if ChannelManager.sharedManager.channels != nil {
            cell = loadingCellForTableView(tableView)
        }
        else {
            cell = channelCellForTableView(tableView, atIndexPath: indexPath)
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    // MARK: - Internal methods
    
    func loadingCellForTableView(tableView: UITableView) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("loadingCell")!
    }
    
    func channelCellForTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let menuCell = tableView.dequeueReusableCellWithIdentifier("channelCell", forIndexPath: indexPath) as! MenuTableCell
        
        let channel = ChannelManager.sharedManager.channels![indexPath.row]
        var friendlyName = channel.friendlyName
        if let name = channel.friendlyName where name.isEmpty {
            friendlyName = name
        }
        menuCell.channelName = friendlyName
        return menuCell
    }
    
    func populateChannels() {
        ChannelManager.sharedManager.populateChannelsWithCompletion { success in
            if !success {
                AlertDialogController.showAlertWithMessage("Failed to load channels",
                    title: "IP Messaging Demo",
                    presenter: self)
            }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func refreshChannels() {
        refreshControl.beginRefreshing()
        populateChannels()
    }
    
    // MARK: - TwilioIPMessagingClientDelegate
    
    func ipMessagingClient(client: TwilioIPMessagingClient!, channelAdded channel: TWMChannel!) {
        tableView.reloadData()
    }
    
    func ipMessagingClient(client: TwilioIPMessagingClient!, channelChanged channel: TWMChannel!) {
        tableView.reloadData()
    }

    func ipMessagingClient(client: TwilioIPMessagingClient!, channelDeleted channel: TWMChannel!) {
        tableView.reloadData()
    }
    
    // MARK: - Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
