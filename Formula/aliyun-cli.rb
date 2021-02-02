class AliyunCli < Formula
  desc "Universal Command-Line Interface for Alibaba Cloud"
  homepage "https://github.com/aliyun/aliyun-cli"
  url "https://github.com/aliyun/aliyun-cli/archive/v3.0.69.tar.gz"
  sha256 "63fbe349ed1394e35b846be40dde6ef9949da4c431af0a93c30d9f0d171d2c43"
  license "Apache-2.0"

  bottle do
    cellar :any_skip_relocation
    sha256 "ee5c3e65afac02f97067bdb8d4dc62e0e8914fcd3a62db5e664334f3705af435" => :big_sur
    sha256 "80acdf57680db7a8c04c10cf0d052115685cf34ecf5e4d53f12336db8379a704" => :arm64_big_sur
    sha256 "7fce8f65771b9d5f2eaf4d0a0bee81e6a39a3d0e863d46f9b095af4c40d9614a" => :catalina
    sha256 "60bdb7a637d2c509b60462a659c56c1d3c222076523c8ed6774ab3d5539cc5d8" => :mojave
  end

  depends_on "go" => :build

  def install
    ENV["GO111MODULE"] = "off"
    ENV["GOPATH"] = buildpath
    ENV["PATH"] = "#{ENV["PATH"]}:#{buildpath}/bin"
    (buildpath/"src/github.com/aliyun/aliyun-cli").install buildpath.children
    cd "src/github.com/aliyun/aliyun-cli" do
      system "make", "metas"
      system "go", "build", "-o", bin/"aliyun", "-ldflags",
                            "-X 'github.com/aliyun/aliyun-cli/cli.Version=#{version}'", "main/main.go"
    end
  end

  test do
    version_out = shell_output("#{bin}/aliyun version")
    assert_match version.to_s, version_out

    help_out = shell_output("#{bin}/aliyun --help")
    assert_match "Alibaba Cloud Command Line Interface Version #{version}", help_out
    assert_match "", help_out
    assert_match "Usage:", help_out
    assert_match "aliyun <product> <operation> [--parameter1 value1 --parameter2 value2 ...]", help_out

    oss_out = shell_output("#{bin}/aliyun oss")
    assert_match "Object Storage Service", oss_out
    assert_match "aliyun oss [command] [args...] [options...]", oss_out
  end
end
