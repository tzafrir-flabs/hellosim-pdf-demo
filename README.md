# HelloSim: PDF from a URL

A minimal SwiftUI app that loads a PDF over HTTPS and shows every page.

1. The first screen shows a link to a PDF.
2. Tap the link. The app downloads the file with `URLSession` and shows a spinner.
3. PDFKit's `PDFView` shows all pages in one vertical scroll. The title shows the page count.
4. If the download fails, the screen shows the error and a "Try again" button.

All the code is in [`HelloSim/HelloSimApp.swift`](HelloSim/HelloSimApp.swift). The app has no dependencies.

## Requirements

- Xcode 16 or later
- iOS 17 or later (simulator or device)

## Run it

Open `HelloSim.xcodeproj` in Xcode, select an iPhone simulator, and press Run.

Or use the command line:

```bash
xcodebuild -project HelloSim.xcodeproj -scheme HelloSim \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## Use your own PDF

Change `pdfURL` at the top of `HelloSimApp.swift`. The URL must use HTTPS (App Transport Security blocks plain HTTP).

The URL in this repo points to a temporary public file. That file will be deleted soon, and then the app shows its error screen. Use your own URL instead.
