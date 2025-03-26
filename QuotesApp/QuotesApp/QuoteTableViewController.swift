//
//  QuoteTableViewController.swift
//  QuotesApp
//
//  Created by Jeanette on 2/21/25.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController {
    let productID = "io.github.jemui.QuotesApp.PremiumQuotes"
    let storeManager = StoreManager.shared
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        if(isPurchased()) {
            showPremiumQuotes()
        }
          
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return isPurchased() ? quotesToShow.count : quotesToShow.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        let index = indexPath.row
        
        // Configure the cell...
        cell.textLabel?.numberOfLines = 0
        if index < quotesToShow.count {
            cell.textLabel?.text = quotesToShow[index]
            cell.textLabel?.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
            cell.accessoryType = .none
        }
        else {
            cell.textLabel?.text = "Get More Quotes"
            cell.textLabel?.textColor = .blue
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count {
            buyPremiumQuotes()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func buyPremiumQuotes() {
        storeManager.fetchProduct { product in
            if let product = product {
                print("Product Loaded: \(product.displayName) - \(product.price)")
                let priceString = product.price.formatted(.currency(code: product.priceFormatStyle.currencyCode))
                    
                let alert = UIAlertController(
                    title: "Purchase \(product.displayName)?",
                    message: "Price: \(priceString)",
                    preferredStyle: .alert
                )

                let buyAction = UIAlertAction(title: "Buy", style: .default) { _ in
                    self.storeManager.purchase { success, message in
                        if success {
                            print("Purchase successful!")
                            self.showPremiumQuotes()
                        } else {
                            print("Purchase failed: \(message ?? "Unknown error")")
                        }
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

                alert.addAction(buyAction)
                alert.addAction(cancelAction)

                self.present(alert, animated: true)
            } else {
                print("Failed to load product.")
            }
        }
        
//        storeManager.purchase { success, message in
//            if success {
//                print("Purchase successful!")
//                // Unlock content here
//            } else {
//                print("Purchase failed: \(message ?? "Unknown error")")
//            }
//        }
    }
    
    private func isPurchased() -> Bool {
        let purchaseStatus = UserDefaults.standard.bool(forKey: productID)
        return purchaseStatus
    }
    
    
    private func showPremiumQuotes() {
        UserDefaults.standard.set(true, forKey: self.productID)
        
        quotesToShow.append(contentsOf: premiumQuotes)
        tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        Task { @MainActor in
            let restorePurchase = await storeManager.restorePurchases()
            print("[d] restore purchase:<##> \(restorePurchase)")
            if restorePurchase {
                self.showPremiumQuotes()
                navigationItem.setRightBarButton(nil, animated: true)
            }
        }
    }


}
