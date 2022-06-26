class Emojify < Formula
  desc "Emoji on the command-line :scream:"
  homepage "https://github.com/mrowa44/emojify"
  url "https://github.com/mrowa44/emojify/archive/refs/tags/2.2.0.tar.gz"
  sha256 "340b866c432705989f71a61551c92af55f49f14d8f17b2c63a0db99e2d687e55"
  license "MIT"
  head "https://github.com/mrowa44/emojify.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "525c599c9e16d63627d5b4afca9f43d22e456d21a8e00a05b5e4a4e2acded629"
  end

  def install
    bin.install "emojify"
  end

  test do
    input = "Hey, I just :raising_hand: you, and this is :scream: , but here's my :calling: , " \
            "so :telephone_receiver: me, maybe?"
    assert_equal "Hey, I just 🙋 you, and this is 😱 , but here's my 📲 , so 📞 me, maybe?",
      shell_output("#{bin}/emojify \"#{input}\"").strip
  end
end
