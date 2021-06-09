import UIKit
import Combine

import CommonKit
import PokemonFoundation

/// A `UITableViewController` subclass for displaying `Pokédex.Entry` objects.
public final class PokédexViewController: UIViewController {
    
    private lazy var tableView = lazyTableView()
    private lazy var searchController = lazySearchController()
    private lazy var activityIndicator = lazyActivityIndicator()
    
    private let service: PokémonService
    private let dataSource: SearchableDataSource<Pokédex.Entry>
    private let decorator: PokédexCellDecorator
    private let refresher: PokédexRefreshController
        
    private var cancellables = Set<AnyCancellable>()
    
    public init(menuItemActions: [PokédexMenuItemAction]) {
        guard let service = PokémonService.instance() else {
            fatalError("Programmer error! Could not create \(type(of: PokémonService.self))")
        }
        
        let refresher = PokédexRefreshController(service: service)
        let menuProvider = PokédexCellMenuProvider(
            menuItemActions: menuItemActions + [ViewPokémonSpritesAction(service: service)]
        )
        
        self.service = service
        self.dataSource = SearchableDataSource(
            itemPublisher: refresher.entriesSubject.eraseToAnyPublisher()
        )
        self.decorator = PokédexCellDecorator(menuProvider: menuProvider)
        self.refresher = refresher
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PokédexViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
                
        title = LocalizedString.title.value
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.constrain(to: view)
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.constrain(to: view)
                
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        
        dataSource.$displaySections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancellables)
        
        decorator.menuProvider.presentSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.present($0.itemAction, forItemAt: $0.indexPath) }
            .store(in: &cancellables)
        
        refresher.refresh(animated: false)
    }
}
    
extension PokédexViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return dataSource.displaySections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.displaySections[section].items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PokédexCellDecorator.Cell = tableView.dequeueReusableCell(for: indexPath)!
        let item = dataSource.item(at: indexPath)
        
        decorator.decorate(cell, for: tableView, using: item)

        return cell
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return dataSource.displaySections[section].title
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        return dataSource.collation.sectionIndexTitles
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return dataSource.displaySections.firstIndex(where: { $0.title == title }) ?? index
    }
}

extension PokédexViewController: UITableViewDelegate {
            
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //swiftlint:disable:next:force_cast
        let cell = cell as! PokédexCellDecorator.Cell
        decorator.tearDown(cell, for: tableView)
    }
}

extension PokédexViewController: UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        dataSource.searchText = searchController.searchBar.text?.nilIfEmpty
    }
}

extension PokédexViewController {
    
    private func present(_ itemAction: PokédexMenuItemAction, forItemAt indexPath: IndexPath) {
        let item = dataSource.item(at: indexPath)
        
        DispatchQueue.main.async { [weak self] in self?.activityIndicator.startAnimating() }
        
        service.pokémonPublisher(for: item.url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self, weak itemAction] result in
                if self?.activityIndicator.isAnimating == true {
                    self?.activityIndicator.stopAnimating()
                }
                
                switch result {
                case .success(let pokémon):
                    guard let viewController = itemAction?.viewController(for: pokémon) else {
                        self?.presentError()
                        return
                    }
                    
                    DispatchQueue.main.async { self?.show(viewController, sender: self) }
                    
                case .failure:
                    self?.presentError()
                }
            }
            .store(in: &cancellables)
    }
    
    private func presentError() {
        DispatchQueue.main.async { [weak self] in
            self?.presentSingleActionAlert(
                alerTitle: LocalizedString.errorTitle.value,
                message: LocalizedString.errorMessage.value,
                actionTitle: LocalizedString.okText.value
            )
        }
    }
}

extension PokédexViewController {
    
    private func lazyTableView() -> UITableView {
        let tableView = UITableView()
        tableView.refreshControl = refresher.refreshControl
        tableView.delegate = self
        tableView.dataSource = self
        
        decorator.configure(tableView)
        
        return tableView
    }
    
    private func lazySearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = LocalizedString.placeHolder.value
        
        return searchController
    }
    
    private func lazyActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }
}

extension PokédexViewController {
    
    private enum LocalizedString: String {
        case placeHolder = "searchable-list.searchbar.placeholder.text"
        case title = "pokedex-viewcontroller.title.text"
        case errorTitle = "pokedex-viewcontroller.error.title.text"
        case errorMessage = "pokedex-viewcontroller.error.message.text"
        case okText = "pokedex-viewcontroller.ok.button.text"
                
        var value: String { Bundle.module.localizedString(forKey: rawValue, comment: nil)}
    }
}
