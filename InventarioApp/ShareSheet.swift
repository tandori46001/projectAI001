import SwiftUI
import UIKit
import WebKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// PDF generation from HTML
func generatePDFFromHTML(_ html: String, completion: @escaping (URL?) -> Void) {
    let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 595, height: 842))
    let coordinator = PDFCoordinator(completion: completion)
    webView.navigationDelegate = coordinator

    // Store coordinator to prevent deallocation
    objc_setAssociatedObject(webView, "coordinator", coordinator, .OBJC_ASSOCIATION_RETAIN)

    webView.loadHTMLString(html, baseURL: nil)
}

class PDFCoordinator: NSObject, WKNavigationDelegate {
    let completion: (URL?) -> Void

    init(completion: @escaping (URL?) -> Void) {
        self.completion = completion
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let config = WKPDFConfiguration()
        config.rect = CGRect(x: 0, y: 0, width: 595, height: 842)

        webView.createPDF(configuration: config) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let url = FileManager.default.temporaryDirectory.appendingPathComponent("inventario.pdf")
                    try? data.write(to: url)
                    self.completion(url)
                case .failure:
                    self.completion(nil)
                }
            }
        }
    }
}
