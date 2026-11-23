require_relative "../lib/outloud_token"

class Outloud < Formula
  desc "Project templates and AI coding agent setup, for developers"
  homepage "https://cli.outloud.dev"
  url "https://cli.outloud.dev/cli/1.0.4.tgz",
      headers: ["Authorization: Bearer #{OutloudToken.read}"]
  sha256 "5dcf9bbe0d64863133c80f0f92a48ba7fee3217c03dbe6465f79d26afea0b6e2"

  livecheck do
    url "https://cli.outloud.dev/cli/latest.json"
    strategy :json do |json|
      json["latest"]
    end
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  def caveats
    <<~EOS
      Downloads need your personal token. If an install or upgrade fails with
      HTTP 401, sign in again with: curl -fsSL https://cli.outloud.dev/install.sh | sh
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/outloud --version")
  end
end
