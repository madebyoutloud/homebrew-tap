require_relative "../lib/outloud_token"

class Outloud < Formula
  desc "Project templates and AI coding agent setup, for developers"
  homepage "https://cli.outloud.dev"
  url "https://cli.outloud.dev/cli/2.0.1.tgz",
      headers: ["Authorization: Bearer #{OutloudToken.read}"]
  sha256 "ddfb954825d11e81cb3f3754e1b7d69c48d7fc1f4756bc6b155c46405180e3d6"

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
