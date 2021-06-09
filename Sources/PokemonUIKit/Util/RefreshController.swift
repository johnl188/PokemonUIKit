import UIKit
import Combine

/// A `protocol` describing properties to aid in refreshing view content.
protocol RefreshController {
    
    /// A `UIRefreshControl` control configured to refresh a view resource.
    var refreshControl: UIRefreshControl { get }
    
    /// A method called to manually begin a refresh cycle.
    func refresh(animated: Bool)
}
