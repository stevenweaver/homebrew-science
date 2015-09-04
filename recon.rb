class Recon < Formula
  homepage "http://www.repeatmasker.org/RepeatModeler.html"
  # doi "10.1101/gr.88502"
  # tag "bioinformatics"
  url "http://www.repeatmasker.org/RECON-1.07.tar.gz"
  sha1 "215ef7d47d41faf657bcb4ee211019ed713e399e"

  bottle do
    cellar :any
    sha256 "b3e222db9633614433c6cabd5c2ee46c78f18194421cb4e8df0820608eb90d22" => :yosemite
    sha256 "c3d875ca2a2715e03be0cb439d3848c6bc5fb19e80bec51ea2d296bbdcf03d27" => :mavericks
    sha256 "5b1e6e98ae5a2b9dc18ca9d7a1de74db21fe1b7918498e12019e7a3e72ff12d1" => :mountain_lion
  end

  def install
    inreplace "scripts/recon.pl", '$path = "";', "$path = \"#{bin}\";"
    bin.mkdir
    system *%W[make -C src]
    system *%W[make -C src install BINDIR=#{bin} MANDIR=#{man}]
    bin.install Dir["scripts/*"]
    doc.install %W[00README COPYRIGHT INSTALL LICENSE]
  end

  test do
    assert_match "usage", shell_output("#{bin}/recon.pl 2>&1", 255)
  end
end
