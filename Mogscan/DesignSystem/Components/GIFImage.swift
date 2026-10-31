import SwiftUI
import WebKit

/// A lightweight, GPU-accelerated GIF playback view using WebKit.
/// Handles high-resolution animated GIFs with transparency and hardware scaling.
struct GIFImage: View {
    let name: String

    var body: some View {
        GIFWebView(name: name)
    }
}

private struct GIFWebView: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.isUserInteractionEnabled = false

        loadGIF(in: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    private func loadGIF(in webView: WKWebView) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif") ??
                        Bundle.main.url(forResource: name, withExtension: nil),
              let data = try? Data(contentsOf: url) else {
            return
        }

        let base64 = data.base64EncodedString()
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                html, body {
                    width: 100%;
                    height: 100%;
                    background: transparent;
                    overflow: hidden;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                }
                img {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                }
            </style>
        </head>
        <body>
            <img src="data:image/gif;base64,\(base64)" />
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}

#Preview {
    ZStack {
        AppBackground()
        GIFImage(name: "futureself")
            .frame(width: 250, height: 250)
            .clipShape(Circle())
    }
    .preferredColorScheme(.dark)
}
