import UIKit
import Combine

import CommonKit

/// A `Combine` wrapper around a set of published items to be displayed in a `UITableViewController.`
final class SearchableDataSource<Item: Searchable> {
    
    let collation = UILocalizedIndexedCollation.current()
    
    private var sections: [Section<Item>] = []
    @Published private(set) var displaySections: [Section<Item>] = []
    
    @Published var searchText: String? = nil
    private var cancellables = Set<AnyCancellable>()
    
    init(itemPublisher: AnyPublisher<[Item], Never>) {                
        itemPublisher
            .removeDuplicates()
            .sink { [weak self] items in
                let sections = self?.sections(from: items) ?? []
                
                self?.sections = sections
                self?.displaySections = (self?.searchText)
                    .flatMap { self?.filtered(sections: sections, by: $0) }
                    ?? sections
            }
            .store(in: &cancellables)
        
        $searchText
            .handleEvents(receiveOutput: { [weak self] in
                guard $0?.nilIfEmpty == nil else {
                    return
                }
                
                self?.displaySections = self?.sections ?? []
            })
            .compactMap { $0?.nilIfEmpty }
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.displaySections = (self?.sections)
                    .flatMap { self?.filtered(sections: $0, by: searchText) }
                    ?? []
            }
            .store(in: &cancellables)
    }
}

extension SearchableDataSource {
    
    func item(at indexPath: IndexPath) -> Item {
        
        return displaySections[indexPath.section].items[indexPath.row]
    }
}

extension SearchableDataSource {
    
    private func sections(from items: [Item]) -> [Section<Item>] {
        let selector: Selector = #selector(getter: Item.identifier)

        return items
            .reduce(into: [Int: [Item]]()) {
                let key = collation.section(for: $1, collationStringSelector: selector)
                
                $0[key, default: []].append($1)
            }
            .compactMap { Section(title: collation.sectionTitles[$0.key], items: $0.value) }
            .sorted { $0.title.lowercased() < $1.title.lowercased() }
    }
    
    private func filtered(sections: [Section<Item>], by searchText: String) -> [Section<Item>] {
        let searchTerms = searchText
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespaces)
            .filter { $0 != "" }
        
        return sections.compactMap { $0.filtered(by: searchTerms) }
    }
}

extension SearchableDataSource {
    
    struct Section<Item: Searchable> {
        let title: String
        let items: [Item]
        
        init?(title: String, items: [Item]) {
            guard !items.isEmpty else { return nil }
            
            self.title = title
            self.items = items
        }
        
        func filtered(by searchTerms: [String]) -> Section? {
            
            return Section(
                title: title,
                items: items.filter { $0.identifier.contains(elements: searchTerms) }
            )
        }
    }
}
