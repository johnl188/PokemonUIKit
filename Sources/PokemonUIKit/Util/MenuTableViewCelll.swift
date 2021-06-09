import UIKit
import Combine

/// A `UITableViewCell` subclass that shows a `UIMenu` when selected.
final class MenuTableViewCell: UITableViewCell {
    
    private lazy var button = lazyButton()
    
    var menu: UIMenu? {
        get { button.menu }
        set {
            button.menu = newValue
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.constrain(to: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MenuTableViewCell {
 
    private func lazyButton() -> Button {
        let button = Button(type: .system)
        button.configure(
            onWillDisplay: { [weak self] in self?.isSelected = true },
            onWillEnd: { [weak self] in self?.isSelected = false }
        )
        
        return button
    }
}

extension MenuTableViewCell {
    
    private final class Button: UIButton {
        
        private var onWillDisplay: (() -> ())?
        private var onWillEnd: (() -> ())?
        
        func configure(onWillDisplay: @escaping () -> (), onWillEnd: @escaping () -> ()) {
            self.onWillDisplay = onWillDisplay
            self.onWillEnd = onWillEnd
            showsMenuAsPrimaryAction = true
        }
        
        override func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            willDisplayMenuFor configuration: UIContextMenuConfiguration,
            animator: UIContextMenuInteractionAnimating?
        ) {
            
            animator?.addAnimations { [weak self] in self?.onWillDisplay?() }
        }
        
        override func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            willEndFor configuration: UIContextMenuConfiguration,
            animator: UIContextMenuInteractionAnimating?
        ) {
            
            animator?.addAnimations { [weak self] in self?.onWillEnd?() }
        }
    }
}
