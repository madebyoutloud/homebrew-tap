require_relative "../lib/outloud_token"

class OutloudAi < Formula
  desc "AI guidelines and skills for coding agents"
  homepage "https://cli.outloud.dev"
  url "https://cli.outloud.dev/ai/1.2.0.tgz",
      headers: ["Authorization: Bearer #{OutloudToken.read}"]
  sha256 "5069280f741af58e98ee42624a12fcbbff6fd8bfc67bac649106af464b327474"

  livecheck do
    url "https://cli.outloud.dev/ai/latest.json"
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
      Downloads need your personal token from https://cli.outloud.dev.
      If an install or upgrade fails with HTTP 401, open https://cli.outloud.dev,
      sign in and run the setup command again.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/outloud-ai --version")
  end
end
