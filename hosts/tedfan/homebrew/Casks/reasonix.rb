cask "reasonix" do
  arch arm: "arm64", intel: "amd64"

  version "2.42.0"
  sha256 arm:   "52816ef65ba8a0cb8b8a728bd57b2b3024c039d88a4d22ed515ccbdb07c0f9e3",
         intel: "b91f3aab65a03d9de8d782b805e22bd0c7a92dba785bc45369ca2d16f19ae82b"

  url "https://github.com/esengine/DeepSeek-Reasonix/releases/download/studio-v#{version}/reasonix-darwin-#{arch}.tar.gz"
  name "Reasonix"
  desc "Cache-first DeepSeek coding agent for the terminal"
  homepage "https://github.com/esengine/DeepSeek-Reasonix"

  depends_on :macos

  binary "reasonix"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{staged_path}/reasonix"]
  end
end
