//
//  ViewController.swift
//  ConverterTest
//
//  Created by Michał Smulski on 23/01/2019.
//  Copyright © 2019 Michał Smulski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let repository = CurrenciesRepository(service: CurrenciesService(baseUrl: URL(string: "https://revolut.duckdns.org")!))
    private var rates: [Rate] = []
    private let baseIndexPath = IndexPath(row: 0, section: 0)
    private var baseRate: Rate? {
        guard baseIndexPath.row < rates.count else { return nil }
        return rates[baseIndexPath.row]
    }
    private var baseAmount: Double = 100
    private var baseCurrency: String {
        return baseRate?.currencyCode ?? "GBP"
    }
    private lazy var refreshTimer = CustomTimer(deadline: DispatchTime.now() + 2.0, repeatingInterval: 1.0) { [weak self] in
        self?.refreshCurrenciesTable() {
            self?.reloadTableView(startIndex: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
        
        refreshCurrenciesTable() {
            self.tableView.reloadData()
            self.refreshTimer.start()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    private func update(_ cell: CurrencyTableViewCell, withRate rate: Rate) {
        cell.display(rate: rate)
        cell.delegate = self
        cell.display(amount: repository.convert(baseAmount, of: baseCurrency, to: rate.currencyCode))
    }
    
    private func update(_ cell: CurrencyTableViewCell, at indexPath: IndexPath) {
        let rate = rates[indexPath.row]
        update(cell, withRate: rate)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.id, for: indexPath) as! CurrencyTableViewCell
        update(cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rates.count
    }
}

extension ViewController: CurrencyTableViewCellDelegate {
    func didEnterAmount(amountString: String, cell: CurrencyTableViewCell) {
        updateBaseAmount(to: amountString)
        reloadTableView(startIndex: 1)
    }
    
    fileprivate func moveEditedCellToTop(cellIndexPath indexPath: IndexPath) {
        let rateToMove = rates[indexPath.row]
        rates.remove(at: indexPath.row)
        rates.insert(rateToMove, at: baseIndexPath.row)
        tableView.moveRow(at: indexPath, to: baseIndexPath)
    }
    
    func didBeginEditing(cell: CurrencyTableViewCell, textField: UITextField) {
        guard let indexPath = tableView.indexPath(for: cell), indexPath != baseIndexPath else { return }
        
        self.refreshTimer.suspend()
        updateBaseAmount(to: textField.text ?? "")
        
        tableView.performBatchUpdates({
            moveEditedCellToTop(cellIndexPath: indexPath)
        }, completion: { finished in
            self.refreshCurrenciesTable() {
                self.reloadTableView()
                self.refreshTimer.start()
            }
        })
    }
}

private extension ViewController {
    func refreshCurrenciesTable(completion: (() -> Void)? = nil) {
        repository.requestLatestTable(base: baseCurrency) { [weak self] rates in
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                // TODO: sort new rates to match order of previous one
                self.rates = rates
                completion?()
            }
        }
    }
    
    func reloadTableView(startIndex: Int = 0) {
        (startIndex...tableView.numberOfRows(inSection: baseIndexPath.section))
            .map { IndexPath(row: $0, section: baseIndexPath.section) }
            .reduce([], { (accum, elem) -> [(cell: CurrencyTableViewCell, indexPath: IndexPath)] in
                guard let cell = tableView.cellForRow(at: elem) as? CurrencyTableViewCell else {
                    return accum
                }
                var accumCopy = accum
                accumCopy.append((cell, elem))
                return accumCopy
            })
            .forEach { pair in
                self.update(pair.cell, at: pair.indexPath)
            }
    }
    
    func updateBaseAmount(to amountString: String) {
        self.baseAmount = Double(amountString) ?? 0.0
    }
}
