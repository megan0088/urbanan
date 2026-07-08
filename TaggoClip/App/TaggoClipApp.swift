import SwiftUI
 
@main
struct TaggoClipApp: App {
    @UIApplicationDelegateAdaptor(ClipAppDelegate.self) private var appDelegate
    private let dependencies = ClipDependencies.live
    @State private var invocationHolder = InvocationURLHolder()
 
    var body: some Scene {
        WindowGroup {
            ReportView(
                viewModel: ReportViewModel(
                    resolveScannedItemUseCase: dependencies.makeResolveScannedItemUseCase(),
                    reportFoundItemUseCase: dependencies.makeReportFoundItemUseCase()
                ),
                invocationURL: invocationHolder.url
            )
            .onOpenURL { url in
                invocationHolder.url = url
            }
            .onAppear {
                ClipInvocationBridge.shared.onURLReceived = { url in
//                    print("invocation", url)
                    invocationHolder.url = url
                }
            }
            #if DEBUG
            .task {
                if invocationHolder.url == nil {
                    try? await Task.sleep(for: .seconds(1))
                    if invocationHolder.url == nil {
                        print("no")
                        invocationHolder.url = URL(string: "https://urbanantaggo.netlify.app/item/F4138F1B-7087-4628-99F0-20D467CF0B24")
                    }
                }
            }
            #endif
        }
    }
}
