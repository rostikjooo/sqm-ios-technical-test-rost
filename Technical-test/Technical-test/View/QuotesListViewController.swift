//
//  QuotesListViewController.swift
//  Technical-test
//
//  Created by Patrice MIAKASSISSA on 29.04.21.
//

import UIKit

class QuotesListViewController: UIViewController {
    
    private let dataManager: QuotesDataManager = .init()
    private var market: Market!
    
    private let table: UITableView = .init()
    
    init(market: Market) {
        super.init(nibName: nil, bundle: nil)

        self.market = market
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = market.marketName
        
        addSubviews()
        setupAutolayout()
        fetchQuotes()
    }
    
    private func addSubviews() {
        self.view.addSubview(table)
        
        table.separatorStyle = .none
        table.register(QuoteCell.self, forCellReuseIdentifier: "QuoteCell")
        table.dataSource = self
        table.delegate = self
    }
    
    private func setupAutolayout() {
        let guide = view!
        table.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: guide.topAnchor),
            table.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            table.leftAnchor.constraint(equalTo: guide.leftAnchor),
            table.rightAnchor.constraint(equalTo: guide.rightAnchor)
        ])
    }

    private func fetchQuotes() {
        Task {
            let result = await dataManager.fetchQuotes()
            let mapped = result.map { quotes in
                quotes.map(dataManager.markQuotesWhichFavoriteIfNeeded(_:))
            }
            await MainActor.run { [weak self] in
                self?.reloadQuotes(with: mapped)
            }
        }
    }
    
    private func reloadQuotes(with result: Result<[Quote], FetchError>) {
        switch result {
        case .success(let success):
            market.quotes = success
            updateQuotes()
        case .failure(let failure):
            show(error: failure)
        }
    }
    
    private func updateQuotes() {
        let selectedRows = table.indexPathsForSelectedRows

        table.reloadData()

        DispatchQueue.main.async {
            selectedRows?.forEach { [unowned self] selectedRow in
                self.table.selectRow(at: selectedRow, animated: false, scrollPosition: .none)
            }
        }
    }
    
    private func show(error: FetchError) {
        let description: String
        switch error {
        case .noConnection:
            description = "No internet connection"
        case .serverError:
            description = "Something went wrong"
        }
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        present(alert, animated: true)
    }
    
    private func showDetail(quote: Quote) {
        let detail = QuoteDetailsViewController(
            quote: quote,
            didToggleIsFavorite: { [weak self] quote in
                self?.didToggleIsFavorite(for: quote)
            }
        )
        self.show(detail, sender: self)
    }
    
    private func didToggleIsFavorite(for quote: Quote) {
        let updated = dataManager.toggleIsFavorite(for: quote)
        guard let index = market.quotes?.firstIndex(of: quote) else { return }
        
        market.quotes?[index] = updated
        dataManager.saveLocalStorage()
        
        updateQuotes()
    }
    
}

extension QuotesListViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        market.quotes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let quote = market.quotes?[indexPath.row] else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "QuoteCell", for: indexPath
        ) as! QuoteCell
        
        cell.apply(quote: quote)
        
        return cell
    }
    
    
}

extension QuotesListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let quote = market.quotes?[indexPath.row] else { return }
        showDetail(quote: quote)
    }
    
}
