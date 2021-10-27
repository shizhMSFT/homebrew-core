class Rubyfmt < Formula
  desc "Ruby autoformatter"
  homepage "https://github.com/penelopezone/rubyfmt"
  url "https://github.com/penelopezone/rubyfmt/archive/v0.7.6.tar.gz"
  sha256 "0e2c46263cde6c43c6373869bf996566e8cad9e44f4009fe6f57182b17b9edc3"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "93a5eab5b30e0ff0728557a9f51ce501cc9454fb7c6616b89f5a41d7be96e493"
    sha256 cellar: :any_skip_relocation, big_sur:       "bcdd675a98a38a40e6fa8a7bbb780524665c863bd3fefda5e222d952363630a2"
    sha256 cellar: :any_skip_relocation, catalina:      "8d9ed80d496220e02b9df146c41870079116cf798ab90734212d3cdc6080bb8b"
    sha256 cellar: :any_skip_relocation, mojave:        "8d9ed80d496220e02b9df146c41870079116cf798ab90734212d3cdc6080bb8b"
    sha256 cellar: :any_skip_relocation, high_sierra:   "8d9ed80d496220e02b9df146c41870079116cf798ab90734212d3cdc6080bb8b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ac11feb657dbe095a59e0bbbe1e8adbd8fe5eaa6dd989e36204780697b200e92"
  end

  uses_from_macos "ruby"

  def install
    system "make"
    bin.install "build/rubyfmt.rb" => "rubyfmt"
  end

  test do
    (testpath/"test.rb").write <<~EOS
      def foo; 42; end
    EOS
    expected = <<~EOS
      def foo
        42
      end
    EOS
    assert_equal expected, shell_output("#{bin}/rubyfmt #{testpath}/test.rb")
  end
end
