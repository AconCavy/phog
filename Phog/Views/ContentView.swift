import SwiftUI

struct ContentView: View {
    static let viewWidth: CGFloat = 500
    static let viewHeight: CGFloat = 800
    static let notSelected = "Not Selcted"

    @ObservedObject var console: LogConsole
    @ObservedObject var viewModel: ContentViewModel

    init() {
        let console = LogConsole()
        self.console = console
        self.viewModel = ContentViewModel(logger: console)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                HStack {
                    Text("Input Directory")
                        .bold()
                    Image(systemName: "questionmark.circle")
                        .help("A URL pointing to a directory of images.")
                }

                Text(viewModel.input?.path ?? ContentView.notSelected)
                Button("Select Input Directory") {
                    Task {
                        if let url = await getDirectoryURL() {
                            await MainActor.run { viewModel.input = url }
                        }
                    }
                }
            }

            Group {
                HStack {
                    Text("Output Directory")
                        .bold()
                    Image(systemName: "questionmark.circle")
                        .help("A file URL that points to the output location for this request.")
                }

                Text(viewModel.output?.path ?? ContentView.notSelected)
                Button("Select Output Directory") {
                    Task {
                        if let url = await getDirectoryURL() {
                            await MainActor.run { viewModel.output = url }
                        }
                    }
                }
            }

            Group {
                HStack {
                    Text("Output Filename")
                        .bold()
                    Image(systemName: "questionmark.circle")
                        .help(
                            "A filename that excluding slash, backslash, colon and the end of the dot are allowed."
                        )
                }

                HStack {
                    TextField(ContentViewModel.defaultFilename, text: $viewModel.filename)
                    Picker("Extension", selection: $viewModel.fileExtension) {
                        ForEach(FileExtension.allCases, id: \.self) { value in
                            Text(".\(value.rawValue)")
                        }
                    }
                    .labelsHidden()
                }
            }

            Group {
                HStack {
                    Text("Sample Ordering")
                        .bold()
                    Image(systemName: "questionmark.circle")
                        .help("The order of the image samples.")
                }

                Picker("Sample Ordering", selection: $viewModel.sampleOrdering) {
                    ForEach(SampleOrdering.allCases, id: \.self) { value in
                        Text(value.rawValue.capitalized)
                    }
                }
                .labelsHidden()
            }

            Group {
                HStack {
                    Text("Feature Sensitivity")
                        .bold()
                    Image(systemName: "questionmark.circle")
                        .help("The precision of landmark detection.")
                }

                Picker("Feature Sensitivity", selection: $viewModel.featureSensitivity) {
                    ForEach(FeatureSensitivity.allCases, id: \.self) { value in
                        Text(value.rawValue.capitalized)
                    }
                }
                .labelsHidden()
            }

            Group {
                HStack {
                    Text("Detail")
                        .bold()
                    Image(systemName: "questionmark.circle")
                        .help(
                            "Supported levels of detail for a request. The texture map sizes Preview(1024x1024), Reduced(2048x2048), Medium(4096x4096), Full(8192x8192), and Raw(8192x8192 multiple) will be generated."
                        )
                }

                Picker("Detail", selection: $viewModel.detail) {
                    ForEach(Detail.allCases, id: \.self) { value in
                        Text(value.rawValue.capitalized)
                    }
                }
                .labelsHidden()
            }

            Group {
                if viewModel.isProcessing {
                    ProgressView("Processing...", value: viewModel.progress)
                    Button("Cancel") {
                        viewModel.cancelGeneration()
                    }
                    .disabled(viewModel.isCancelling)
                } else {
                    Button("Generate") {
                        viewModel.runGeneration()
                    }
                }
            }

            Divider()

            Group {
                HStack {
                    Text("Log")
                        .bold()
                    Spacer()
                    Button("Clear") {
                        console.clear()
                    }
                }

                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(console.output.indices, id: \.self) { index in
                            let (type, message) = console.output[index]
                            switch type {
                            case .log:
                                Text(message)
                            case .warning:
                                Text(message)
                                    .foregroundColor(Color.yellow)
                            case .error:
                                Text(message)
                                    .foregroundColor(Color.red)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: ContentView.viewWidth, minHeight: ContentView.viewHeight)
    }

    @MainActor
    private func getDirectoryURL() async -> URL? {
        let (picker, response) = await openDirectoryPicker()
        return response == .OK ? picker.url : nil
    }

    @MainActor
    private func openDirectoryPicker() async -> (NSOpenPanel, NSApplication.ModalResponse) {
        let rect = NSRect(x: 0, y: 0, width: 500, height: 600)
        let picker = NSOpenPanel(
            contentRect: rect, styleMask: .utilityWindow, backing: .buffered, defer: true)

        picker.canChooseDirectories = true
        picker.canChooseFiles = false

        let response = await picker.begin()
        return (picker, response)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
