class ClaudeDesktopTwins < Formula
  desc "Run several Claude Desktop accounts side by side on macOS (unofficial)"
  homepage "https://github.com/dakiquang/claude-desktop-twins"
  url "https://github.com/dakiquang/claude-desktop-twins/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "7f5a9544bb432709e40ddf4627a972bc42e25a7a20d9138553862ffe1a6a638c"
  license "MIT"
  head "https://github.com/dakiquang/claude-desktop-twins.git", branch: "main"

  depends_on :macos

  def install
    system "swiftc", "-O", "-target", "arm64-apple-macos12",
           "-o", "cdt-helper-arm64", "helper/cdt-helper.swift"
    system "swiftc", "-O", "-target", "x86_64-apple-macos12",
           "-o", "cdt-helper-x86_64", "helper/cdt-helper.swift"
    (libexec/"libexec").mkpath
    system "lipo", "-create", "-output", libexec/"libexec/cdt-helper",
           "cdt-helper-arm64", "cdt-helper-x86_64"
    libexec.install "bin", "lib", "helper"
    bin.install_symlink libexec/"bin/claude-desktop-twins"
    bin.install_symlink libexec/"bin/claude-desktop-twins" => "cdt"
  end

  def caveats
    <<~EOS
      Unofficial, not affiliated with Anthropic.
      Before `brew uninstall`, run `cdt uninstall` to remove the per-account apps.
    EOS
  end

  test do
    # A minimal stand-in for Claude.app, so the test does not need the real app.
    app = testpath/"Claude.app/Contents"
    (app/"MacOS").mkpath
    (app/"MacOS/Claude").write("#!/bin/sh\n")
    chmod 0755, app/"MacOS/Claude"
    (app/"Info.plist").write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <plist version="1.0"><dict>
        <key>CFBundleShortVersionString</key><string>1.0.0</string>
      </dict></plist>
    XML
    ENV["HOME"] = testpath
    ENV["CLAUDE_APP"] = testpath/"Claude.app"
    system bin/"cdt", "--help"
    assert_match "no accounts yet", shell_output("#{bin}/cdt doctor")
  end
end
