import UIKit

/// A `protocol` describing methods for decorating a list view's cells.
///
/// Intended for use with both `UITableView`s and `UICollectionView`s
protocol CellDecorator {
    
    associatedtype Item
    associatedtype Cell
    associatedtype ListView
    
    /// A method called to configure a`ListView` to render the decorator's cells.
    ///
    /// - Parameter listView: The `ListView` to be configured.
    func configure(_ listView: ListView)
    
    /// A method that, when called, decorates the given `Cell` parameter using the provided `Item`.
    ///
    /// - Parameters:
    ///   - cell: The `Cell` to be decorated.
    ///   - item: The `Item` used to decorate the `Cell`.
    func decorate(_ cell: Cell, for listView: ListView, using item: Item)
    
    /// A method called when a `ListView` is about to end displaying a `Cell`.
    ///
    /// - Parameter cell: The `Cell` about to leave the screen.
    func tearDown(_ cell: Cell, for listView: ListView)
}
