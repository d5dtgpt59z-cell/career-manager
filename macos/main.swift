import Cocoa
import WebKit
final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {
 var window:NSWindow!; var process:Process?
 func applicationDidFinishLaunching(_ notification: Notification) {
  let root = Bundle.main.resourceURL!.path
  let server = Process(); server.executableURL = URL(fileURLWithPath:"/usr/bin/python3"); server.arguments = [root + "/server.py"]
  var env = ProcessInfo.processInfo.environment; env["CAREER_PORT"] = "18769"; env["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"; server.environment = env
  do { try server.run(); process=server } catch { let alert=NSAlert();alert.messageText="Could not start Career Manager";alert.informativeText=error.localizedDescription;alert.runModal();NSApp.terminate(nil);return }
  let web=WKWebView(frame:.zero); web.navigationDelegate=self
  window=NSWindow(contentRect:NSRect(x:0,y:0,width:1200,height:820),styleMask:[.titled,.closable,.miniaturizable,.resizable],backing:.buffered,defer:false)
  window.title="Career Manager";window.center();window.contentView=web;window.makeKeyAndOrderFront(nil)
  NSApp.activate(ignoringOtherApps:true)
  waitForServer(web, attempts: 60)
 }
 func waitForServer(_ web: WKWebView, attempts: Int) {
  let url=URL(string:"http://127.0.0.1:18769/api/data")!
  URLSession.shared.dataTask(with:url) { _, response, _ in
   DispatchQueue.main.async {
    if let http=response as? HTTPURLResponse, http.statusCode == 200 { web.load(URLRequest(url:URL(string:"http://127.0.0.1:18769/")!)) }
    else if attempts > 0 { DispatchQueue.main.asyncAfter(deadline:.now()+0.5) { self.waitForServer(web,attempts:attempts-1) } }
    else { let alert=NSAlert();alert.messageText="Career Manager could not start";alert.informativeText="The local service did not become ready. Close and reopen the app.";alert.runModal() }
   }
  }.resume()
 }
 func webView(_ webView:WKWebView,decidePolicyFor navigationAction:WKNavigationAction,decisionHandler:@escaping(WKNavigationActionPolicy)->Void) {
  if let url=navigationAction.request.url, let host=url.host, host != "127.0.0.1" && host != "localhost" { NSWorkspace.shared.open(url); decisionHandler(.cancel);return };decisionHandler(.allow)
 }
 func applicationWillTerminate(_ notification:Notification){if process?.isRunning == true {process?.terminate()}}
 func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication)->Bool { true }
}
let app=NSApplication.shared;let delegate=AppDelegate();app.delegate=delegate;app.setActivationPolicy(.regular);app.run()
