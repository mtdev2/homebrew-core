class AwscliAT1 < Formula
  include Language::Python::Virtualenv

  desc "Official Amazon AWS command-line interface"
  homepage "https://aws.amazon.com/cli/"
  # awscli should only be updated every 10 releases on multiples of 10
  url "https://github.com/aws/aws-cli/archive/1.18.220.tar.gz"
  sha256 "47395f3350d5384247c1644b51902790b0b843dbd6e157153f51ba1b3dc4bae3"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(1(?:\.\d+)+)$/i)
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "8a82c4674187cf419068431c6c20a0f02d74438c80c6c8465b0530b715dd3f22" => :big_sur
    sha256 "742bfa848bcbc6442d150a74ab4cbc9a6c454367038d7e1de8ee99509ce4c286" => :arm64_big_sur
    sha256 "dc78dc24834e0f14ccfa450d6d282ee87a1e308b16f9f7c4223dcf52286ed5e6" => :catalina
    sha256 "2bb21dddc89f399ca016f3fcf12817335fc790cec618077314e197a2351ca291" => :mojave
  end

  keg_only :versioned_formula

  # Some AWS APIs require TLS1.2, which system Python doesn't have before High
  # Sierra
  depends_on "python@3.9"

  uses_from_macos "groff"

  def install
    venv = virtualenv_create(libexec, "python3")
    system libexec/"bin/pip", "install", "-v", "--no-binary", ":all:",
                              "--ignore-installed", buildpath
    system libexec/"bin/pip", "uninstall", "-y", "awscli"
    venv.pip_install_and_link buildpath
    pkgshare.install "awscli/examples"

    rm Dir["#{bin}/{aws.cmd,aws_bash_completer,aws_zsh_completer.sh}"]
    bash_completion.install "bin/aws_bash_completer"
    zsh_completion.install "bin/aws_zsh_completer.sh"
    (zsh_completion/"_aws").write <<~EOS
      #compdef aws
      _aws () {
        local e
        e=$(dirname ${funcsourcetrace[1]%:*})/aws_zsh_completer.sh
        if [[ -f $e ]]; then source $e; fi
      }
    EOS
  end

  def caveats
    <<~EOS
      The "examples" directory has been installed to:
        #{HOMEBREW_PREFIX}/share/awscli/examples
    EOS
  end

  test do
    assert_match "topics", shell_output("#{bin}/aws help")
  end
end
