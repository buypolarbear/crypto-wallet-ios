import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    var amount: String?;
    var to: String?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parseItems { to, amount in
            print(to, amount)
        }
    }
    
    @IBAction func done() {
        guard let extensionContext = self.extensionContext else { return }
        extensionContext.completeRequest(returningItems: extensionContext.inputItems, completionHandler: nil)
    }
    
    @IBAction func payHandler() {
    }
    
    func parseItems(completion: @escaping (String, String) -> Void) {
        guard let items = self.extensionContext?.inputItems as? [NSExtensionItem] else { return }
        
        for item in items {
            if let itemProviders = item.attachments as? [NSItemProvider] {
                for itemProvider in itemProviders {
                    if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                        itemProvider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: { (result, error) -> Void in
                            if let jsonString = result as? String {
                                do {
                                    if let data = jsonString.data(using: .utf8),
                                        let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String, String> {
                                        
                                        if let to = json["to"], let amount = json["amount"] {
                                            completion(to, amount)
                                        }
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
}