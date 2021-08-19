import SwiftUI

struct ContentView: View {
    static let viewWidth: CGFloat = 500
    static let viewHeight: CGFloat = 800
    static let notSelected = "Not Selcted"

    @ObservedObject var viewModel: ContentViewModel = ContentViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Input Directory")
                    .bold()
                Text(viewModel.input.isEmpty ? ContentView.notSelected : viewModel.input)
                Button("Select Input Directory") {
                    openDirectoryPicker { url in
                        viewModel.input = url?.absoluteString ?? ""
                    }
                }
            }

            Group {
                Text("Output Directory")
                    .bold()
                Text(viewModel.output.isEmpty ? ContentView.notSelected : viewModel.output)
                Button("Select Output Directory") {
                    openDirectoryPicker { url in
                        viewModel.output = url?.absoluteString ?? ""
                    }
                }
            }

            Group {
                Text("Output Filename")
                    .bold()
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
                Text("Sample Ordering")
                    .bold()
                Picker("Sample Ordering", selection: $viewModel.sampleOrdering) {
                    ForEach(SampleOrdering.allCases, id: \.self) { value in
                        Text(value.rawValue.capitalized)
                    }
                }
                .labelsHidden()
            }

            Group {
                Text("Feature Sensitivity")
                    .bold()
                Picker("Feature Sensitivity", selection: $viewModel.featureSensitivity) {
                    ForEach(FeatureSensitivity.allCases, id: \.self) { value in
                        Text(value.rawValue.capitalized)
                    }
                }
                .labelsHidden()
            }

            Group {
                Text("Detail")
                    .bold()
                Picker("Detail", selection: $viewModel.detail) {
                    ForEach(Detail.allCases, id: \.self) { value in
                        Text(value.rawValue.capitalized)
                    }
                }
                .labelsHidden()
            }

            Group {
                Button("Generate") {
                    viewModel.generatePhotogrammetry()
                }

                if viewModel.isProcessing {
                    ProgressView("Processing...", value: viewModel.progress)
                }
            }

            Divider()

            Group {
                HStack {
                    Text("Log")
                        .bold()
                    Spacer()
                    Button("Clear") {
                        viewModel.logger.clear()
                    }
                }

                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel.logger.output.indices, id: \.self) { index in
                            let (type, message) = viewModel.logger.output[index]
                            switch type {
                            case .log:
                                Text(message)
                                    .foregroundColor(Color.white)
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
        .frame(width: ContentView.viewWidth, height: ContentView.viewHeight)
    }

    private func openDirectoryPicker(callback: ((URL?) -> Void)? = nil) {
        let rect = NSRect(x: 0, y: 0, width: 500, height: 600)
        let picker = NSOpenPanel(
            contentRect: rect, styleMask: .utilityWindow, backing: .buffered, defer: true)

        picker.canChooseDirectories = true
        picker.canChooseFiles = false

        guard let callback = callback else {
            return
        }

        picker.begin { response in
            if response == .OK {
                callback(picker.url)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
