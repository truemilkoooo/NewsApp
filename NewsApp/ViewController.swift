//
//  ViewController.swift
//  NewsApp
//
//  Created by Вова Пупкин on 13.07.2022.
//

import UIKit
import SafariServices

// tableView
// Custom Cell
// API Caller
// Open news
// Search news

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()
    private let searchVC = UISearchController(searchResultsController: nil)
    
    private var articles = [Article]()
    private var viewModels = [NewsTableViewCellViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
        
        fetchTopStories()
        createSearchBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    private func createSearchBar() {
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
    }
    
    private func fetchTopStories() {
        APICaller.shared.getTopStories { [weak self] result in
        switch result {
        case.success(let articles):
            self?.articles = articles
            self?.viewModels = articles.compactMap({NewsTableViewCellViewModel(
                title: $0.title,
                subtitle: $0.description ?? "No Description",
                imageURL: URL(string: $0.urlToImage ?? "")
            )
            })
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        case .failure(let error):
            print(error)
        }
        }
    }
    
//table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath)
        as? NewsTableViewCell else {
            fatalError()
        }
        cell.configurate(with: viewModels[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]
        
        guard let url = URL(string: article.url ?? "") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
//search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        
        APICaller.shared.search(with: text) { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(
                    title: $0.title,
                    subtitle: $0.description ?? "No Description",
                    imageURL: URL(string: $0.urlToImage ?? "")
                )
                })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.dismiss(animated: true, completion: nil)
                }
                
            case .failure(let error):
                print(error)
            }
            }
                    
        }
}

