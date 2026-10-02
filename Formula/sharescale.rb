class Sharescale < Formula
  desc "Keep the display scale of a Mac you control with Screen Sharing at 1x or 2x"
  homepage "https://github.com/taki-0105a/ShareScale"
  url "https://github.com/taki-0105a/ShareScale/releases/download/v1.0.0/sharescale-1.0.0.tar.gz"
  sha256 "7ec33e497a0b3eecd0c5df41e174a90b1f46362a8ee126e613e280b9c939a1dc"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  def install
    # Homebrew's sandbox cannot nest SwiftPM's sandbox (same as std_swift_args).
    ENV["SHARESCALE_SWIFTPM_NO_SANDBOX"] = "1"
    # Builds build/ShareScale.app (with ShareScale Host.app inside) and signs it ad hoc.
    # Retries with --build-system native only for the known Command Line Tools issue.
    system "scripts/build-sharescale.sh"
    prefix.install "build/ShareScale.app"
  end

  def caveats
    <<~EOS
      Open ShareScale for the first time with:
        open "#{opt_prefix}/ShareScale.app"
      It copies itself to ~/Applications/ShareScale.app and runs from there.
      ShareScale targets macOS 14 Sonoma or later but has only been tested on macOS 27.

      After `brew upgrade sharescale`, quit ShareScale (menu bar > Quit ShareScale)
      and open it again to switch to the new version.

      To uninstall, first choose ShareScale > Settings > General >
      "Remove ShareScale Completely…", then run `brew uninstall sharescale`.
    EOS
  end

  test do
    app = prefix/"ShareScale.app"
    # Read the version from Info.plist without a shell (no quoting of paths) and without launching the app.
    info = (app/"Contents/Info.plist").read
    assert_match "<key>CFBundleShortVersionString</key><string>#{version}</string>", info
    assert_path_exists app/"Contents/Library/LoginItems/ShareScale Host.app/Contents/MacOS/ShareScaleHost"
    system "/usr/bin/codesign", "--verify", "--deep", "--strict", app
  end
end
