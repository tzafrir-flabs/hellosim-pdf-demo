import PDFKit
import SwiftUI

private let pdfURL = URL(string: "https://storage.googleapis.com/tmp-pdf-f29cde4e7ebd/job-description.pdf")!

@main
struct HelloSimApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    Section("Documents") {
                        NavigationLink {
                            PDFScreen(url: pdfURL)
                        } label: {
                            Label {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Job description (PDF)")
                                    Text(pdfURL.absoluteString)
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }
                            } icon: {
                                Image(systemName: "doc.richtext")
                            }
                        }
                        .accessibilityIdentifier("pdfLink")
                    }
                }
                .navigationTitle("PDF test")
            }
        }
    }
}

struct PDFScreen: View {
    let url: URL

    private enum LoadState {
        case loading
        case loaded(PDFDocument)
        case failed(String)
    }

    @State private var state: LoadState = .loading

    var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView("Loading PDF…")
            case .loaded(let document):
                PDFKitView(document: document)
                    .ignoresSafeArea(edges: .bottom)
            case .failed(let message):
                ContentUnavailableView {
                    Label("Could not load the PDF", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Try again") { Task { await load() } }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private var title: String {
        if case .loaded(let document) = state {
            return "\(document.pageCount) pages"
        }
        return "PDF"
    }

    private func load() async {
        state = .loading
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                state = .failed("The server returned HTTP \(http.statusCode).")
                return
            }
            guard let document = PDFDocument(data: data) else {
                state = .failed("The file is not a valid PDF.")
                return
            }
            state = .loaded(document)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.displaysPageBreaks = true
        view.autoScales = true
        view.backgroundColor = .secondarySystemBackground
        view.document = document
        return view
    }

    func updateUIView(_ view: PDFView, context: Context) {
        if view.document !== document {
            view.document = document
        }
    }
}
