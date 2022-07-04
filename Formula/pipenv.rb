class Pipenv < Formula
  include Language::Python::Virtualenv

  desc "Python dependency management tool"
  homepage "https://github.com/pypa/pipenv"
  url "https://files.pythonhosted.org/packages/a2/d1/50890e2d3b018230cecf3e0d2597b6cc2d535f6a8b84bf3f9981e42ad989/pipenv-2022.7.4.tar.gz"
  sha256 "18420fbae2851d2b9d70d1e00f77a8c55d09704a177fe872a0a2da56e98eb018"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "b13deb536e0676b6e40266aa061a78706d2d7be4166a098cd1e7db912ba13778"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "86230b8730d7c14f1c84e57546b42c9d190b385acce8a1918dcc5dac6c974488"
    sha256 cellar: :any_skip_relocation, monterey:       "65a14e232883fde3c5a6c63f705790a27767950246fbeee06b089423020f86bf"
    sha256 cellar: :any_skip_relocation, big_sur:        "dff877347de085ef6b97d10bf561a6c86aad0af8f57d4b34a1c2e5e519858330"
    sha256 cellar: :any_skip_relocation, catalina:       "8af57cf76b2d1168da661d18c72d4ffa751c5bbb79eea6f984b40935c648d7e8"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "a235f21a870624aca0096f44ef4b6b07da80b88e459bd4b8281dccdee6e7b4a8"
  end

  depends_on "python@3.10"
  depends_on "six"
  depends_on "virtualenv"

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/cc/85/319a8a684e8ac6d87a1193090e06b6bbb302717496380e225ee10487c888/certifi-2022.6.15.tar.gz"
    sha256 "84c85a9078b11105f04f3036a9482ae10e4621616db313fe045dd24743a0820d"
  end

  resource "virtualenv-clone" do
    url "https://files.pythonhosted.org/packages/85/76/49120db3bb8de4073ac199a08dc7f11255af8968e1e14038aee95043fafa/virtualenv-clone-0.5.7.tar.gz"
    sha256 "418ee935c36152f8f153c79824bb93eaf6f0f7984bae31d3f48f350b9183501a"
  end

  def install
    # Using the virtualenv DSL here because the alternative of using
    # write_env_script to set a PYTHONPATH breaks things.
    # https://github.com/Homebrew/homebrew-core/pull/19060#issuecomment-338397417
    venv = virtualenv_create(libexec, "python3")
    venv.pip_install resources
    venv.pip_install buildpath

    # `pipenv` needs to be able to find `virtualenv` on PATH. So we
    # install symlinks for those scripts in `#{libexec}/tools` and create a
    # wrapper script for `pipenv` which adds `#{libexec}/tools` to PATH.
    (libexec/"tools").install_symlink libexec/"bin/pip", libexec/"bin/virtualenv"
    env = {
      PATH: "#{libexec}/tools:$PATH",
    }
    (bin/"pipenv").write_env_script(libexec/"bin/pipenv", env)

    output = Utils.safe_popen_read(
      { "_PIPENV_COMPLETE" => "zsh_source" }, libexec/"bin/pipenv", { err: :err }
    )
    (zsh_completion/"_pipenv").write output

    output = Utils.safe_popen_read(
      { "_PIPENV_COMPLETE" => "fish_source" }, libexec/"bin/pipenv", { err: :err }
    )
    (fish_completion/"pipenv.fish").write output
  end

  # Avoid relative paths
  def post_install
    lib_python_path = Pathname.glob(libexec/"lib/python*").first
    lib_python_path.each_child do |f|
      next unless f.symlink?

      realpath = f.realpath
      rm f
      ln_s realpath, f
    end
  end

  test do
    ENV["LC_ALL"] = "en_US.UTF-8"
    assert_match "Commands", shell_output("#{bin}/pipenv")
    system "#{bin}/pipenv", "--python", Formula["python@3.10"].opt_bin/"python3"
    system "#{bin}/pipenv", "install", "requests"
    system "#{bin}/pipenv", "install", "boto3"
    assert_predicate testpath/"Pipfile", :exist?
    assert_predicate testpath/"Pipfile.lock", :exist?
    assert_match "requests", (testpath/"Pipfile").read
    assert_match "boto3", (testpath/"Pipfile").read
  end
end
