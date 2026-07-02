/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that renders Google Search suggestions with links that allow users
to view the search results in the device's default browser.
*/

import SwiftUI
import WebKit

/// A view that renders Google Search suggestions with links that allow users
/// to view the search results in the device's default browser.
struct GoogleSearchSuggestionView: UIViewRepresentable {
  let htmlString: String

  // This Coordinator class will act as the web view's navigation delegate.
  class Coordinator: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      // Check if the navigation was triggered by a user clicking a link.
      if navigationAction.navigationType == .linkActivated {
        if let url = navigationAction.request.url {
          // Open the URL in the system's default browser (e.g., Safari).
          UIApplication.shared.open(url)
        }
        // Cancel the navigation inside our small web view.
        decisionHandler(.cancel)
        return
      }
      // For all other navigation types (like the initial HTML load), allow it.
      decisionHandler(.allow)
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.isOpaque = false
    webView.backgroundColor = .clear
    webView.scrollView.backgroundColor = .clear
    webView.scrollView.isScrollEnabled = false
    // Set the coordinator as the navigation delegate.
    webView.navigationDelegate = context.coordinator
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {
    // The renderedContent is an HTML snippet with CSS.
    // For it to render correctly, we wrap it in a basic HTML document structure.
    let fullHTML = """
    <!DOCTYPE html>
    <html>
    <head>
      <meta name='viewport' content='width=device-width, initial-scale=1.0, user-scalable=no'>
      <style>
        body { margin: 0; padding: 0; }
      </style>
    </head>
    <body>
      \(htmlString)
    </body>
    </html>
    """
    uiView.loadHTMLString(fullHTML, baseURL: nil)
  }
}
