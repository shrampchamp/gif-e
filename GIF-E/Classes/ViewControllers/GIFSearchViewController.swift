//
//  GIFSearchViewController.swift
//  GIF-E
//
//  Created by Cam on 7/20/20.
//  Copyright © 2020 Cam Hunt. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyGif
import WaterfallLayout

class GIFSearchViewController: UIViewController {
    
    let api = API()
    
    var collectionView: UICollectionView!
    var firstAppearance = true
    
    var nextPageRequest: DataRequest?
    var response: GiphyResponse?
    var currentQuery: String?
    
    var gifs = [GIF]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        title = "GIF-E"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = WaterfallLayout()
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        navigationController?.navigationBar.tintColor = .systemGreen
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController?.searchResultsUpdater = self
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController?.automaticallyShowsCancelButton = false
        
        collectionView.backgroundColor = .systemBackground
        collectionView.keyboardDismissMode = .onDrag
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GIFCell.self, forCellWithReuseIdentifier: "GIFCell")
        
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppearance {
            navigationItem.searchController?.searchBar.becomeFirstResponder()
            firstAppearance = false
        }
    }
    
    // MARK: - actions -
    
    func debouncedSearch(query: String) {
        currentQuery = query
        nextPageRequest?.cancel()
        nextPageRequest = nil
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(search), object: nil)
        self.perform(#selector(search), with: nil, afterDelay: 0.4)
    }
    
    @objc func search() {
        guard let query = currentQuery else {
            return
        }
        response = nil
        gifs.removeAll()
        api.request(
            GiphyRequest.search(query: query),
            expectedType: GiphyResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.response = response
                self.gifs = response.data
            case .failure(let error):
                self.handle(error)
            }
        }
    }
    
    func deboucnedNextPage() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getNextPageIfNeeded), object: nil)
        self.perform(#selector(getNextPageIfNeeded), with: nil, afterDelay: 0.4)
    }
    
    @objc func getNextPageIfNeeded() {
        guard nextPageRequest == nil,
            let response = response,
            response.morePagesExpected == true,
            let query = currentQuery else {
            return
        }
        
        nextPageRequest = api.request(
            GiphyRequest.search(query: query, offset: response.nextOffset),
            expectedType: GiphyResponse.self
        ) { [weak self] result in
            guard let self = self else { return }
            self.nextPageRequest = nil
            switch result {
            case .success(let response):
                self.response = response
                self.gifs.append(contentsOf: response.data)
            case .failure(let error):
                self.handle(error)
            }
        }
    }
    
    // MARK: - helpers -
    
    func handle(_ error: Error) {
        switch error {
        case URLError.cancelled: ()
        // if the request gets cancelled, fail silently
        default:
            alert(error)
        }
    }
    
    func alert(_ error: Error) {
        let alertController = UIAlertController(
            title: "Uh oh!",
            message: "Looks like something went wrong! Try again\n\n(\(error.localizedDescription))",
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil
            )
        )
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - keyboard appearance -
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
            let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        
        let keyboardHeight = view.frame.height - targetFrame.origin.y
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [UIView.AnimationOptions(rawValue: curve)],
            animations: {
                self.collectionView.contentInset = insets
                self.collectionView.scrollIndicatorInsets = insets
        },
            completion: nil
        )
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate -

extension GIFSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // detects if we are within 100 points of the bottom of the scroll view
        let actualY = scrollView.contentOffset.y
        guard scrollView.contentSize.height > 100, actualY >= 0 else { return }
        let triggerY = scrollView.contentSize.height - scrollView.frame.size.height - 100
        if actualY >= triggerY {
            deboucnedNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GIFCell", for: indexPath)
        
        let gif = gifs[indexPath.row]
        
        if let gifCell = cell as? GIFCell {
            gifCell.imageView.setGifFromURL(gif.images.fixedWidth.url, levelOfIntegrity: .default, showLoader: true)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let gif = gifs[indexPath.row]
        
        var placeholder: UIImage?
        
        if let cell = collectionView.cellForItem(at: indexPath) as? GIFCell {
            placeholder = cell.imageView.gifImage
        }
        
        let detailViewController = GIFDetailViewController(gif: gif, placeholder: placeholder)
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - WaterfallLayoutDelegate -

extension GIFSearchViewController: WaterfallLayoutDelegate {
    func collectionViewLayout(for section: Int) -> WaterfallLayout.Layout {
        switch traitCollection.horizontalSizeClass {
        case .compact, .unspecified:
            return .waterfall(column: 2, distributionMethod: .equal)
        case .regular:
            return .waterfall(column: 5, distributionMethod: .equal)
        @unknown default:
            return .waterfall(column: 2, distributionMethod: .equal)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let gif = gifs[indexPath.row]
        return CGSize(width: gif.images.fixedWidth.width.value, height: gif.images.fixedWidth.height.value)
    }
}

// MARK: - UISearchResultsUpdating & UISearchControllerDelegate -

extension GIFSearchViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text.nilIfEmpty() else {
            gifs.removeAll()
            return
        }
        guard searchQuery != currentQuery else {
            return
        }
        debouncedSearch(query: searchQuery)
    }
}
