import SwiftUI

struct ContentView: View {
    let viewWidth: CGFloat = 500
    let viewHeight: CGFloat = 800

    @ObservedObject var viewModel: ContentViewModel = ContentViewModel()

    @State var filename = ""
    @State var sampleOrdering = ContentViewModel.SampleOrdering.none
    @State var featureSensitivity = ContentViewModel.FeatureSensitivity.none
    @State var detail = ContentViewModel.Detail.medium

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Input Directory")
                    .bold()
                Text(viewModel.input)
                Button("Select Input Directory") {
                    openDirectoryPicker(callback: viewModel.setInput)
                }
            }

            Group {
                Text("Output Directory")
                    .bold()
                Text(viewModel.output)
                Button("Select Output Directory") {
                    openDirectoryPicker(callback: viewModel.setOutput)
                }
            }

            Group {
                Text("Output Filename")
                    .bold()
                TextField(
                    viewModel.defaultFilename, text: $filename,
                    onCommit: {
                        viewModel.setFilename(filename: filename)
                    })
            }

            Group {
                Text("Sample Ordering")
                    .bold()
                Picker("Sample Ordering", selection: $sampleOrdering) {
                    ForEach(ContentViewModel.SampleOrdering.allCases, id: \.self) { value in
                        Text(value.rawValue.capitalized)
                    }
                }
                .onChange(of: sampleOrdering, perform: viewModel.setSampleOrdering)
                .labelsHidden()
            }

            Group {
                Text("Feature Sensitivity")
                    .bold()
                Picker("Feature Sensitivity", selection: $featureSensitivity) {
                    ForEach(ContentViewModel.FeatureSensitivity.allCases, id: \.self) { value in
                        Text(value.rawValue.capitalized)
                    }
                }
                .onChange(of: featureSensitivity, perform: viewModel.setFeatureSensitivity)
                .labelsHidden()
            }

            Group {
                Text("Detail")
                    .bold()
                Picker("Detail", selection: $detail) {
                    ForEach(ContentViewModel.Detail.allCases, id: \.self) { value in
                        Text(value.rawValue.capitalized)
                    }
                }
                .onChange(of: detail, perform: viewModel.setDetail)
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
        .frame(width: viewWidth, height: viewHeight)
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
