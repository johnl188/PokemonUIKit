import UIKit

import PokemonFoundation

/// A `CellDecorator` implementation for displaying `Pokédex` content.
///
/// - SeeAlso: `CellDecorator`.
final class PokédexCellDecorator: CellDecorator {
    
    let menuProvider: PokédexCellMenuProvider
    
    init(menuProvider: PokédexCellMenuProvider) {
        self.menuProvider = menuProvider
    }
}

extension PokédexCellDecorator {
    
    func configure(_ tableView: UITableView) {
        tableView.register(MenuTableViewCell.self)

        tableView.estimatedRowHeight = Constant.rowHeight
        tableView.rowHeight = Constant.rowHeight
        tableView.sectionHeaderHeight = Constant.headerFooterHeight
        tableView.sectionFooterHeight = Constant.headerFooterHeight
    }
    
    func decorate(_ cell: MenuTableViewCell, for tableView: UITableView, using entry: Pokédex.Entry) {
        cell.textLabel?.text = entry.displayText
        cell.menu = menuProvider.menu(for: cell, in: tableView)
    }
    
    func tearDown(_ cell: MenuTableViewCell, for tableView: UITableView) {
        cell.textLabel?.text = nil
        cell.menu = nil
    }
}

extension PokédexCellDecorator {
    
    enum Constant {
        
        static var rowHeight: CGFloat { 44.0 }
        
        static var headerFooterHeight: CGFloat { 28.0 }
    }
}
