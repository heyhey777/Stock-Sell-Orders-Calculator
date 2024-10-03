import StoreKit

@MainActor
class Store: ObservableObject {
    @Published private(set) var calculationsRemaining: Int {
        didSet {
            UserDefaults.standard.set(calculationsRemaining, forKey: "calculationsRemaining")
        }
    }
    @Published private(set) var isPurchased = false
    @Published private(set) var products: [Product] = []
    @Published private(set) var isProductLoading = false
    @Published var errorMessage: String?
    
    private let productId = "com.sellsmart.fullaccess"
    private var transactionListener: Task<Void, Error>?
    
    init() {
        self.calculationsRemaining = UserDefaults.standard.integer(forKey: "calculationsRemaining")
        if self.calculationsRemaining == 0 {
            self.calculationsRemaining = 30
        }
        transactionListener = listenForTransactions()
        Task {
            await updatePurchaseStatus()
            await requestProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.handlePurchase(transaction)
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    func requestProducts() async {
        isProductLoading = true
        errorMessage = nil
        do {
            print("Requesting products for ID: \(productId)")
            #if DEBUG
            // Use this for local testing with StoreKit Configuration file
            products = try await Product.products(for: [productId])
            #else
            // Use this for TestFlight and Production
            products = try await Product.products(for: [productId])
            #endif
            print("Received \(products.count) products")
            if products.isEmpty {
                errorMessage = "No products available"
                print("Product array is empty")
            } else {
                for product in products {
                    print("Product: \(product.id), \(product.displayName), \(product.displayPrice)")
                }
            }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("Failed to request products: \(error)")
            if let skError = error as? SKError {
                print("SKError code: \(skError.errorCode)")
            }
        }
        isProductLoading = false
    }
    
    func updatePurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try await checkVerified(result)
                await handlePurchase(transaction)
            } catch {
                print("Failed to update purchase status: \(error)")
            }
        }
    }
    
    func purchase() async {
           guard let product = products.first else {
               errorMessage = "No product available"
               return
           }
           
           do {
               let result = try await product.purchase()
               
               switch result {
               case .success(let verification):
                   let transaction = try await checkVerified(verification)
                   await handlePurchase(transaction)
                   await transaction.finish()
               case .userCancelled:
                   errorMessage = "Purchase cancelled"
               case .pending:
                   errorMessage = "Purchase pending"
               @unknown default:
                   errorMessage = "Unknown purchase result"
               }
           } catch {
               errorMessage = "Purchase failed: \(error.localizedDescription)"
           }
       }
    
    func handlePurchase(_ transaction: Transaction) async {
        if transaction.productID == productId {
            isPurchased = true
            calculationsRemaining = Int.max
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) async throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    func useCalculation() {
        if !isPurchased && calculationsRemaining > 0 {
            calculationsRemaining -= 1
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
