require "language/node"

class ReleaseIt < Formula
  desc "Generic CLI tool to automate versioning and package publishing related tasks"
  homepage "https://github.com/release-it/release-it"
  url "https://registry.npmjs.org/release-it/-/release-it-17.4.2.tgz"
  sha256 "4dde3ed255103a8b7afd885e47f9767fd4274ea7f53f9525f37f1b5d0dd96bb4"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "0b7d4662e0812034e857b2e9340d668515b1165143a14c5e7a3de6cbccc7ff3d"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "0b7d4662e0812034e857b2e9340d668515b1165143a14c5e7a3de6cbccc7ff3d"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "0b7d4662e0812034e857b2e9340d668515b1165143a14c5e7a3de6cbccc7ff3d"
    sha256 cellar: :any_skip_relocation, sonoma:         "b93ce13b59342fe44e8ac65b361bef303fb5ed99e7c1a86a7b0d9e496f88951b"
    sha256 cellar: :any_skip_relocation, ventura:        "b93ce13b59342fe44e8ac65b361bef303fb5ed99e7c1a86a7b0d9e496f88951b"
    sha256 cellar: :any_skip_relocation, monterey:       "b93ce13b59342fe44e8ac65b361bef303fb5ed99e7c1a86a7b0d9e496f88951b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "06e862c69ea0af85967511379bd785dc9529a94bdd8f881b051379d451c42bbb"
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/release-it -v")
    (testpath/"package.json").write("{\"name\":\"test-pkg\",\"version\":\"1.0.0\"}")
    assert_match(/Let's release test-pkg.+\(1\.0\.0\.\.\.1\.0\.1\).+Empty changelog.+Done \(in \d+s\.\)/m,
      shell_output("#{bin}/release-it --npm.skipChecks --no-npm.publish --ci"))
    assert_match "1.0.1", (testpath/"package.json").read
  end
end
