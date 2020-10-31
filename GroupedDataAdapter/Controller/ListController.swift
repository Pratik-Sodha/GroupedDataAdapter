//
//  ListController.swift
//  GroupedDataAdapter
//
//  Created by APPLE on 28/10/20.
//

import UIKit

class ListController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView : UITableView! {
        didSet {
            tableView.keyboardDismissMode = .interactive
            tableView.tableFooterView = UIView.init(frame: .zero)
        }
    }
    @IBOutlet weak var searchBar : UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }

    //MARK:- Class Variable
    lazy var tableBackgroundView : EmptyBackGroundView? = {
        return EmptyBackGroundView(UIImage(named: "nothing-found"), "No Data Found.")
    }()
    
    lazy var leftBarSortButtomItem : UIBarButtonItem = {
        return UIBarButtonItem(title: "Sort Group", style: .plain, target: self, action: #selector(leftBarSortGroupButtonClicked(_:)))
    }()
    
    lazy var rightBarSortButtomItem : UIBarButtonItem = {
        return UIBarButtonItem(title: "Group Item Sort", style: .plain, target: self, action: #selector(rightBarSortItemButtonClicked(_:)))
    }()
    
    let groups = WebSeires.loadUsingJSON().adapterGrouping { (seires) -> String in
        return seires.group
    }
    
    lazy var adapter : GroupedDataAdapter = {
        GroupedDataAdapter(groups: groups.keys, items: groups.values)
    }()
    
    var groupSortOption : GroupSortOption = .default  {
        didSet {
            adapter.groupSortComparator = groupSortOption.sortDescriptor
            tableView.reloadData()
            leftBarSortButtomItem.title = groupSortOption.buttonTitle
        }
    }

    //MARK:- Custom Methods
    func setupView() {
        navigationItem.leftBarButtonItems = [leftBarSortButtomItem]
        navigationItem.rightBarButtonItems = [rightBarSortButtomItem]
    }
    
    func reloadTableAndBackGroundViewIfNeeded() {
        tableView.backgroundView = adapter.isEmpty ? tableBackgroundView : nil
        tableView.reloadData()
    }
    
    //MARK:- IBAction
    @objc func rightBarSortItemButtonClicked(_ sender : UIBarButtonItem) {
        let controller = SortOptionController.loadController()
        controller.delegateSortOptionSelection = self
        present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
    }
    
    @objc func leftBarSortGroupButtonClicked(_ sender : UIBarButtonItem) {
        groupSortOption.next()
    }
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }


}
//MARK:
extension ListController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return adapter.operationalGroups.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return adapter.operationalGroups[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let group = adapter.operationalGroups[section]
        return adapter.operationalItems[group]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let group = adapter.operationalGroups[indexPath.section]
        let itemAtIndex = adapter.operationalItems[group]?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableCell.cellReusableIdentifer) as! DetailTableCell
        cell.series = itemAtIndex

        return cell
    }
}

//MARK:-
extension ListController : SortOptionSelectionDelegate {
    
    func sortOptionController(_ controller: SortOptionController, didSelect option: SortOption) {
        
        adapter.itemSortComparator = option.sortDescriptor
        tableView.reloadData()
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ListController : UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.isEmpty else {
            adapter.filterBlock = nil
            reloadTableAndBackGroundViewIfNeeded()
            return
        }
        
        adapter.filterBlock = {seireses in
            return seireses.filter { (seires) -> Bool in
                return seires.name.lowercased().contains(text.lowercased())
            }
        }
        reloadTableAndBackGroundViewIfNeeded()
    }
}
