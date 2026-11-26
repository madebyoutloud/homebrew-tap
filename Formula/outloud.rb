require_relative "../lib/outloud_token"

class Outloud < Formula
  desc "Project templates and AI coding agent setup, for developers"
  homepage "https://cli.outloud.dev"
  url "https://cli.outloud.dev/cli/2.0.7.tgz",
      headers: ["Authorization: Bearer #{OutloudToken.read}"]
  sha256 "84f5886964246652a2ab80027c535b0c21e75c828e4619d8e5acdcc771c9b2cc"

  livecheck do
    url "https://cli.outloud.dev/cli/latest.json"
    strategy :json do |json|
      json["latest"]
    end
  end

  # keg-only, so installing outloud never changes the node on PATH
  depends_on "node@24"

  def install
    node = formula_opt_bin("node@24")
    system node/"npm", "install", *std_npm_args
    (bin/"outloud").write_env_script libexec/"bin/outloud", PATH: "#{node}:$PATH"
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
