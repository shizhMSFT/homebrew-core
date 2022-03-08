class Algol68g < Formula
  desc "Algol 68 compiler-interpreter"
  homepage "https://jmvdveer.home.xs4all.nl/algol.html"
  # The upstream download url currently returns a 404 error.
  # Until fixed, we can use a copy from OpenBSD.
  url "https://ftp.openbsd.org/pub/OpenBSD/distfiles/algol68g-3.0.4.tar.gz"
  mirror "https://jmvdveer.home.xs4all.nl/algol68g-3.0.4.tar.gz"
  sha256 "26bace5ded60aefab7dbde3a34b007b3cd31b26605e68dd229688da856e9f870"
  license "GPL-3.0-or-later"

  # The homepage hasn't been updated for the latest release (2.8.5), even though
  # the related archive is available on the site. Until the website is updated
  # (and seems like it will continue to be updated for new releases), we're
  # checking a third-party source for new releases as an interim solution.
  livecheck do
    url "https://openports.se/lang/algol68g"
    regex(/href=.*?algol68g[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "98edac632999d9493f86e738c6fdec7782cde8d07768c6a495681cd5de0103a4"
    sha256                               arm64_big_sur:  "5e90719ca013bddd6066b0e1e87d6162094ee73ef300233f1f75d9833bf4dc42"
    sha256                               monterey:       "1f5961932f3fac98be74b6d33e23f1a91cfe48e3173ef4b5c9cb94743cdeb10a"
    sha256                               big_sur:        "7b7bb03b6cbe89d253b5e88294ecc4edf61a0687c4534f26ffb7422efe22e52d"
    sha256                               catalina:       "046ba5e9ec0d0856557085fdf1acde227cd829d9955da28046e98c9a5ee84c09"
    sha256                               mojave:         "7e1acd53615ebc407aaae64eb23af6047dbbd42f967e422b3fcfa0c6d01307b6"
    sha256                               high_sierra:    "18013401e3eed914022e0a34c6b9b1ed415ec679113de78970d74aa52b0a35e8"
    sha256                               x86_64_linux:   "3db30a51c50dc264cf0f7d261fb936a17ffad5cb14f73b105e44a69a10d56f30"
  end

  depends_on "gcc"

  uses_from_macos "ncurses"

  on_linux do
    depends_on "mpfr"
    depends_on "postgresql"
  end

  fails_with :clang do
    cause <<-EOS
      configure: error: stop -- C compiler does not support __attribute__aligned directive
      conftest.c:17:25: error: function definition is not allowed here
      inline void skip (void) {;}
                              ^
    EOS
  end

  # /home/linuxbrew/.linuxbrew/include/mpfr.h:467:50: error: unknown type name '_Float128'
  fails_with gcc: "5"

  def install
    inreplace "Makefile.in" do |s|
      # Work around the hardcoded include directory
      s.gsub! "= /usr/local/include/algol68g", "= #{include}/algol68g"

      # Work around macOS build error. Env variables like LDFLAGS, CFLAGS, DEFS aren't picked up.
      # ./src/a68g/a68glib.c:46:7: error: expected declaration specifiers or '...' before numeric constant
      #    46 |   int vsnprintf (char *, size_t, const char *, va_list);
      #       |       ^~~~~~~~~
      s.gsub!(/^DEFS =.*$/, "\\0 -D_FORTIFY_SOURCE=0") if OS.mac?
    end

    args = std_configure_args
    # On macOS, Homebrew's `mpfr` formula is not built with float128 support
    # and causes errors for undefined symbols "_mpfr_get_float128"
    args << "--disable-mpfr" if OS.mac?

    system "./configure", *args
    system "make", "install"
  end

  test do
    path = testpath/"hello.alg"
    path.write <<~EOS
      print("Hello World")
    EOS

    assert_equal "Hello World", shell_output("#{bin}/a68g #{path}").strip
  end
end
