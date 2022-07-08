class Jolie < Formula
  desc "Service-oriented programming language"
  homepage "https://www.jolie-lang.org/"
  url "https://github.com/jolie/jolie/releases/download/v1.10.10/jolie-1.10.10.jar"
  sha256 "486a9bdc412e69565604bbaef09c281394d6984d0570f3746cd5391f5f78243e"
  license "LGPL-2.1-only"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "56f8f9b008a733c98119fd49c7e966510cc3c502496000d91d0a6d1aa9f10585"
  end

  depends_on "openjdk"

  def install
    system Formula["openjdk"].opt_bin/"java", "-jar", "jolie-#{version}.jar",
                                              "--jolie-home", libexec,
                                              "--jolie-launchers", libexec/"bin"

    bin.install (libexec/"bin").children

    jolie_env = Language::Java.overridable_java_home_env
    jolie_env["JOLIE_HOME"] = "${JOLIE_HOME:-#{libexec}}"
    bin.env_script_all_files libexec/"bin", jolie_env
  end

  test do
    file = testpath/"test.ol"
    file.write <<~EOS
      from console import Console, ConsoleIface

      interface PowTwoInterface { OneWay: powTwo( int ) }

      service main(){

        outputPort Console { interfaces: ConsoleIface }
        embed Console in Console

        inputPort In {
          location: "local://testPort"
          interfaces: PowTwoInterface
        }

        outputPort Self {
          location: "local://testPort"
          interfaces: PowTwoInterface
        }

        init {
          powTwo@Self( 4 )
        }

        main {
          powTwo( x )
          println@Console( x * x )()
        }

      }
    EOS

    out = shell_output("#{bin}/jolie #{file}").strip

    assert_equal "16", out
  end
end
