class Pari < Formula
  desc "Computer algebra system designed for fast computations in number theory"
  homepage "https://pari.math.u-bordeaux.fr/"
  url "https://pari.math.u-bordeaux.fr/pub/pari/unix/pari-2.13.1.tar.gz"
  sha256 "81ecf7d70ccdaae230165cff627c9ce2ec297b8f22f9f40742279d85f86dfcb1"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://pari.math.u-bordeaux.fr/pub/pari/unix/"
    regex(/pari[._-]v?(\d+\.\d+\.\d+)/i)
  end

  bottle do
    sha256 "683db9ffc99f148aa417d3679b8a2f4fa1e9c35ea0e9d657eac258a3b3ddcba7" => :big_sur
    sha256 "bce28f4a6d89eccbed6c8a2a314c1eda9e600eaf924d56c45fe3e219974d59f6" => :arm64_big_sur
    sha256 "40b9dcb1426e44c03657c10af167be08c1ff1d1e1cbfe99d5c3ac724801b3e2e" => :catalina
    sha256 "d7f12a7d997767b7eca8e93a29b5e82f5bb00a7ffd4c4b341968e1442b563872" => :mojave
  end

  depends_on "gmp"
  depends_on "readline"

  def install
    readline = Formula["readline"].opt_prefix
    gmp = Formula["gmp"].opt_prefix
    system "./Configure", "--prefix=#{prefix}",
                          "--with-gmp=#{gmp}",
                          "--with-readline=#{readline}",
                          "--graphic=ps"
    # make needs to be done in two steps
    system "make", "all"
    system "make", "install"

    # Avoid references to Homebrew shims
    inreplace lib/"pari/pari.cfg", HOMEBREW_LIBRARY/"Homebrew/shims/mac/super/", "/usr/bin/"
  end

  def caveats
    <<~EOS
      If you need the graphical plotting functions you need to install X11 with:
        brew install --cask xquartz
    EOS
  end

  test do
    (testpath/"math.tex").write "$k_{n+1} = n^2 + k_n^2 - k_{n-1}$"
    system bin/"tex2mail", testpath/"math.tex"
  end
end
