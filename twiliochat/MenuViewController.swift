import UIKit
import Parse

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

    usernameLabel.text = IPMessagingManager.sharedManager().userIdentity

    refreshControl = UIRefreshControl()
    tableView.addSubview(refreshControl)
    refreshControl.addTarget(self, action: "refreshChannels", forControlEvents: .ValueChanged)
    refreshControl.tintColor = UIColor.whiteColor()

    self.refreshControl.frame.origin.x -= MenuViewController.TWCRefreshControlXOffset
    ChannelManager.sharedManager.delegate = self
    self.populateChannels()
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

  func deselectSelectedChannel() {
    let selectedRow = tableView.indexPathForSelectedRow
    if let row = selectedRow {
      tableView.deselectRowAtIndexPath(row, animated: true)
    }
  }

  // MARK: - Channel

  func createNewChannelDialog() {
    InputDialogController.showWithTitle("New Channel",
      message: "Enter a name for this channel",
      placeholder: "Name",
      presenter: self) { text in
        ChannelManager.sharedManager.createChannelWithName(text, completion: { _,_ in })
    }
  }

  // MARK: Logout

  func promptLogout() {
    let alert = UIAlertController(title: nil, message: "You are about to Logout", preferredStyle: .Alert)

    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { action in
      self.logOut()
    }

    alert.addAction(cancelAction)
    alert.addAction(confirmAction)
    presentViewController(alert, animated: true, completion: nil)
  }

  func logOut() {
    IPMessagingManager.sharedManager().logout()
    IPMessagingManager.sharedManager().presentRootViewController()
  }

  // MARK: - Actions

  @IBAction func logoutButtonTouched(sender: UIButton) {
    promptLogout()
  }

  @IBAction func newChannelButtonTouched(sender: UIButton) {
    createNewChannelDialog()
  }

  // MARK: - Navigation

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == MenuViewController.TWCOpenChannelSegue {
      let indexPath = sender as! NSIndexPath
      let channel = ChannelManager.sharedManager.channels![indexPath.row] as! TWMChannel
      let navigationController = segue.destinationViewController as! UINavigationController
      (navigationController.visibleViewController as! MainChatViewController).channel = channel
    }
  }

  // MARK: - Style

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}

// MARK: - UITableViewDataSource
extension MenuViewController : UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let channels = ChannelManager.sharedManager.channels {
      return channels.count
    }
    return 1
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: UITableViewCell

    if ChannelManager.sharedManager.channels == nil {
      cell = loadingCellForTableView(tableView)
    }
    else {
      cell = channelCellForTableView(tableView, atIndexPath: indexPath)
    }

    cell.layoutIfNeeded()
    return cell
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    if let channel = ChannelManager.sharedManager.channels?.objectAtIndex(indexPath.row) as? TWMChannel {
      return channel != ChannelManager.sharedManager.generalChannel
    }
    return false
  }

  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
    forRowAtIndexPath indexPath: NSIndexPath) {
      if editingStyle != .Delete {
        return
      }
      if let channel = ChannelManager.sharedManager.channels?.objectAtIndex(indexPath.row) {
        channel.destroyWithCompletion { result in
          if result == .Success {
            tableView.reloadData()
          }
          else {
            AlertDialogController.showAlertWithMessage("You can not delete this channel", title: nil, presenter: self)
          }
        }
      }
  }
}

// MARK: - UITableViewDelegate
extension MenuViewController : UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier(MenuViewController.TWCOpenChannelSegue, sender: indexPath)
  }
}

// MARK: - TwilioIPMessagingClientDelegate
extension MenuViewController : TwilioIPMessagingClientDelegate {
  func ipMessagingClient(client: TwilioIPMessagingClient!, channelAdded channel: TWMChannel!) {
    tableView.reloadData()
  }

  func ipMessagingClient(client: TwilioIPMessagingClient!, channelChanged channel: TWMChannel!) {
    tableView.reloadData()
  }

  func ipMessagingClient(client: TwilioIPMessagingClient!, channelDeleted channel: TWMChannel!) {
    tableView.reloadData()
  }
}
