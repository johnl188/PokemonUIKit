import UIKit

import CommonKit
import PokemonFoundation

/// A `CellDecorator` implementation for displaying `Sprites` content.
///
/// - SeeAlso: `CellDecorator`.
final class PokémonSpritesCellDecorator: CellDecorator {
    
    func configure(_ tableView: UITableView) {
        tableView.register(UITableViewCell.self)

        tableView.estimatedRowHeight = Constant.rowHeight
        tableView.rowHeight = Constant.rowHeight
    }
    
    func decorate(_ cell: UITableViewCell, for tableView: UITableView, using group: Pokémon.Sprites.DisplayGroup) {
        cell.textLabel?.text = group.id
        cell.accessoryType = .disclosureIndicator
    }
    
    func tearDown(_ cell: UITableViewCell, for tableView: UITableView) {
        cell.textLabel?.text = nil
        cell.accessoryType = .none
    }
}

extension PokémonSpritesCellDecorator {
    
    enum Constant {
        
        static var rowHeight: CGFloat { 44.0 }
    }
}
