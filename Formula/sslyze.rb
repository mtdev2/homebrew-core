class Sslyze < Formula
  include Language::Python::Virtualenv

  desc "SSL scanner"
  homepage "https://github.com/nabla-c0d3/sslyze"
  license "AGPL-3.0-only"

  stable do
    url "https://files.pythonhosted.org/packages/0b/85/a3a05d338c1860caf491dfa92517c93088f7e9c852600735c83f31375b6a/sslyze-4.0.1.tar.gz"
    sha256 "c5b64a3c13b7a5e9f23ee04158bdcc408822834adb711cfcc98dfcd587eb86dc"

    resource "nassl" do
      url "https://github.com/nabla-c0d3/nassl/archive/4.0.0.tar.gz"
      sha256 "b8a00062bf4cc7cf4fd09600d0a6845840833a8d3c593c0e615d36abac74f36e"
    end
  end

  bottle do
    cellar :any
    sha256 "803e170a2e6371f96887741e51ae8cca487ebfdf7b864d1c871fd00c14a3ec1c" => :big_sur
    sha256 "59f008974fe6cf172d5dd1ec69e144f76208d63688569683980cda09b709d899" => :catalina
    sha256 "80662343bef03f1da2339aa77942455e265e16cd13f2c1e367abcbaf19dd9d1c" => :mojave
  end

  head do
    url "https://github.com/nabla-c0d3/sslyze.git"

    resource "nassl" do
      url "https://github.com/nabla-c0d3/nassl.git"
    end
  end

  depends_on "pipenv" => :build
  depends_on "libffi"
  depends_on "openssl@1.1"
  depends_on "python@3.9"

  resource "cffi" do
    url "https://files.pythonhosted.org/packages/66/6a/98e023b3d11537a5521902ac6b50db470c826c682be6a8c661549cb7717a/cffi-1.14.4.tar.gz"
    sha256 "1a465cbe98a7fd391d47dce4b8f7e5b921e6cd805ef421d04f5f66ba8f06086c"
  end

  resource "cryptography" do
    url "https://files.pythonhosted.org/packages/b7/82/f7a4ddc1af185936c1e4fa000942ffa8fb2d98cff26b75afa7b3c63391c4/cryptography-3.3.1.tar.gz"
    sha256 "7e177e4bea2de937a584b13645cab32f25e3d96fc0bc4a4cf99c27dc77682be6"
  end

  resource "pycparser" do
    url "https://files.pythonhosted.org/packages/0f/86/e19659527668d70be91d0369aeaa055b4eb396b0f387a4f92293a20035bd/pycparser-2.20.tar.gz"
    sha256 "2d475327684562c3a96cc71adf7dc8c4f0565175cf86b6d7a404ff4c771f15f0"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/6b/34/415834bfdafca3c5f451532e8a8d9ba89a21c9743a0c59fbd0205c7f9426/six-1.15.0.tar.gz"
    sha256 "30639c035cdb23534cd4aa2dd52c3bf48f06e5f4a941509c8bafd8ce11080259"
  end

  resource "tls-parser" do
    url "https://files.pythonhosted.org/packages/66/4e/da7f727a76bd9abee46f4035dbd7a4711cde408f286dae00c7a1f9dd9cbb/tls_parser-1.2.2.tar.gz"
    sha256 "83e4cb15b88b00fad1a856ff54731cc095c7e4f1ff90d09eaa24a5f48854da93"
  end

  def install
    venv = virtualenv_create(libexec, "python3.9")

    res = resources.map(&:name).to_set
    res -= %w[nassl]

    res.each do |r|
      venv.pip_install resource(r)
    end

    resource("nassl").stage do
      nassl_path = Pathname.pwd
      inreplace "Pipfile", 'python_version = "3.7"', 'python_version = "3.9"'
      system "pipenv", "install", "--dev"
      system "pipenv", "run", "invoke", "build.all"
      venv.pip_install nassl_path
    end

    venv.pip_install_and_link buildpath
  end

  test do
    assert_match "SCAN COMPLETED", shell_output("#{bin}/sslyze --regular google.com")
    assert_no_match /exception/, shell_output("#{bin}/sslyze --certinfo letsencrypt.org")
  end
end
