class Binutils < Formula
  desc "GNU binary tools for native development"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "https://ftp.gnu.org/gnu/binutils/binutils-2.36.tar.xz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.36.tar.xz"
  sha256 "5788292cc5bbcca0848545af05986f6b17058b105be59e99ba7d0f9eb5336fb8"
  license all_of: ["GPL-2.0-or-later", "GPL-3.0-or-later", "LGPL-2.0-or-later", "LGPL-3.0-only"]

  livecheck do
    url :stable
  end

  bottle do
    sha256 "464fb5fcf20ca249899299a48a210b3be8e9d72b02d62e9b325e8a2638a50b79" => :big_sur
    sha256 "5227a5695421c8471b43801b12e2935a7bbaffbad405552d7473f0c1c36c8d3e" => :arm64_big_sur
    sha256 "c0124975e7089a2f6620325f31833de7c9e85f02aebbb415000ed36262025a55" => :catalina
    sha256 "c9c2f5b15ad2dbb6028a7b4e803cee330dc6803bc670684935b20ff5f8d11e7d" => :mojave
  end

  keg_only :shadowed_by_macos, "Apple's CLT provides the same tools"

  uses_from_macos "zlib"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--enable-deterministic-archives",
                          "--prefix=#{prefix}",
                          "--infodir=#{info}",
                          "--mandir=#{man}",
                          "--disable-werror",
                          "--enable-interwork",
                          "--enable-multilib",
                          "--enable-64-bit-bfd",
                          "--enable-gold",
                          "--enable-plugins",
                          "--enable-targets=all",
                          "--with-system-zlib",
                          "--disable-nls"
    system "make"
    system "make", "install"
    bin.install_symlink "ld.gold" => "gold"
    on_macos do
      Dir["#{bin}/*"].each do |f|
        bin.install_symlink f => "g" + File.basename(f)
      end
    end

    on_linux do
      # Reduce the size of the bottle.
      system "strip", *Dir[bin/"*", lib/"*.a"]
    end
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/strings #{bin}/strings")
  end
end
