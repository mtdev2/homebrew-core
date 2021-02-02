class JpegXl < Formula
  desc "New file format for still image compression"
  homepage "https://jpeg.org/jpegxl/index.html"
  url "https://gitlab.com/wg1/jpeg-xl/-/archive/v0.3/jpeg-xl-v0.3.tar.bz2"
  sha256 "b2b98a03d1527d1c8ecedb5cb745820713c8bdd2489bf234f3ed40757d32e717"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any, big_sur: "6ec8396d0e5ecf22bf0118328bff3abe14bc6f282ec77e83de0cce929b222906"
    sha256 cellar: :any, arm64_big_sur: "9caf551bdd14a71fd59c581b8d26beb53773bfb56f37d6c2677d77726c3c50c7"
    sha256 cellar: :any, catalina: "0d3c0133fbe2a913fbdc91c3bed31bc43cc4d807b68ce80aaf5e425c2e53d833"
    sha256 cellar: :any, mojave: "546395300a16381524b6cf18fbae2a214aa34c716b23a8a8018097a96fc28f92"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "brotli"
  depends_on "giflib"
  depends_on "ilmbase"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "openexr"
  depends_on "webp"

  # These resources are versioned according to the script supplied with jpeg-xl to download the dependencies:
  # https://gitlab.com/wg1/jpeg-xl/-/blob/v#{version}/deps.sh
  resource "highway" do
    url "https://github.com/google/highway.git",
        revision: "311c183c9d96e69b123f61eedc21025dd27be000"
  end

  resource "lodepng" do
    url "https://github.com/lvandeve/lodepng.git",
        revision: "48e5364ef48ec2408f44c727657ac1b6703185f8"
  end

  resource "sjpeg" do
    url "https://github.com/webmproject/sjpeg.git",
        revision: "868ab558fad70fcbe8863ba4e85179eeb81cc840"
  end

  resource "skcms" do
    url "https://skia.googlesource.com/skcms.git",
        revision: "64374756e03700d649f897dbd98c95e78c30c7da"
  end

  def install
    resources.each { |r| r.stage buildpath/"third_party"/r.name }
    mkdir "build" do
      system "cmake", "..", "-DBUILD_TESTING=OFF", *std_cmake_args
      system "cmake", "--build", "."
      system "cmake", "--build", ".", "--target", "install"
    end
  end

  test do
    system "#{bin}/cjxl", test_fixtures("test.jpg"), "test.jxl"
    assert_predicate testpath/"test.jxl", :exist?
  end
end
