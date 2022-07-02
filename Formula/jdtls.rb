class Jdtls < Formula
  desc "Java language specific implementation of the Language Server Protocol"
  homepage "https://github.com/eclipse/eclipse.jdt.ls"
  url "https://download.eclipse.org/jdtls/milestones/1.13.0/jdt-language-server-1.13.0-202206301721.tar.gz"
  version "1.13.0"
  sha256 "5a29ad28d765f408106a87b147b239696942a11f22f950c52dc37176fce9cfc9"
  license "EPL-2.0"
  version_scheme 1

  livecheck do
    url "https://download.eclipse.org/jdtls/milestones/"
    regex(%r{href=.*?/v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, all: "5af62f9cf5c42b7ba320b51901224ca87593475a80d292beeb3cbd9aede5e50f"
  end

  depends_on "openjdk"
  depends_on "python@3.10"

  def install
    libexec.install "bin"
    libexec.install "config_mac"
    libexec.install "config_linux"
    libexec.install "features"
    libexec.install "plugins"

    (bin/"jdtls").write_env_script libexec/"bin/jdtls",
      Language::Java.overridable_java_home_env
  end

  test do
    require "open3"

    json = <<~JSON
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "rootUri": null,
          "capabilities": {}
        }
      }
    JSON

    Open3.popen3("#{bin}/jdtls", "-configuration", "#{testpath}/config", "-data",
        "#{testpath}/data") do |stdin, stdout, _e, w|
      stdin.write "Content-Length: #{json.size}\r\n\r\n#{json}"
      sleep 3
      assert_match(/^Content-Length: \d+/i, stdout.readline)
      Process.kill("KILL", w.pid)
    end
  end
end
