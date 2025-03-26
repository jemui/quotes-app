//
//  StoreManager.swift
//  QuotesApp
//
//  Created by Jeanette on 2/21/25.
//  

import StoreKit

@MainActor
@available(iOS 15.0, *)
class StoreManager {
    static let shared = StoreManager()
    private let productID = "io.github.jemui.QuotesApp.PremiumQuotes"
    var product: Product?

    // Fetch product details
    func fetchProduct(completion: @escaping (Product?) -> Void) {
        Task {
            do {
                let products = try await Product.products(for: [productID])
                Task {
                    self.product = products.first
                    completion(products.first)
                }
            } catch {
                print("Failed to fetch product: \(error)")
                Task {
                    completion(nil)
                }
            }
        }
    }

    // Purchase the product
    func purchase(completion: @escaping (Bool, String?) -> Void) {
        guard let product = product else {
            completion(false, "Product not available.")
            return
        }
        
        Task {
            do {
                let result = try await product.purchase()
                
                Task {
                    switch result {
                    case .success(let verification):
                        if let transaction = try? verification.payloadValue, transaction.revocationDate == nil {
                            print("Purchase successful: \(transaction.productID)")
                            Task { await transaction.finish() }
                            completion(true, nil)
                        } else {
                            completion(false, "Transaction verification failed.")
                        }
                    case .userCancelled:
                        completion(false, "User cancelled the purchase.")
                    case .pending:
                        completion(false, "Purchase is pending.")
                    default:
                        completion(false, "Purchase failed.")
                    }
                }
            } catch {
                Task {
                    completion(false, "Purchase error: \(error.localizedDescription)")
                }
            }
        }
    }

    // Restore purchases
    func restorePurchases() async -> Bool {
        return ((try? await AppStore.sync()) != nil)
    }

    
    // Listen for transaction updates at app launch
    private func listenForTransactionUpdates() {
        Task {
            for await verification in Transaction.updates {
                if case .verified(let transaction) = verification, transaction.productID == productID {
                    print("Processing delayed transaction for: \(transaction.productID)")
                    await transaction.finish()
                }
            }
        }
    }
}
