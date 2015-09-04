require 'formula'

class Qualimap < Formula
  homepage 'http://qualimap.bioinfo.cipf.es/'
  url 'https://bitbucket.org/kokonech/qualimap/downloads/qualimap-build-30-03-15.tar.gz'
  sha1 'ce5c8262493bda49f3eafd2568b11dfc84af7f64'
  version '30-03-15'
  bottle do
    cellar :any
    sha256 "19f916083ad21fe1a05315be7a1ed49c0a7793dddf0f1735af7527ea82e1dd18" => :yosemite
    sha256 "66f1205aee6ae32ce98072e2176f90c37ac456a8b13bb2b1d657af21a0044704" => :mavericks
    sha256 "71fadee98ab35e9d47bd06e9081e32848671b58c3e58c0b718e6fb5743f73f6f" => :mountain_lion
  end
  depends_on 'r' => :optional

  def install
    inreplace 'qualimap', /-classpath [^ ]*/, "-classpath '#{libexec}/*'"
    bin.install 'qualimap'
    libexec.install 'scripts', 'species', 'qualimap.jar', *Dir['lib/*.jar']
    doc.install 'QualimapManual.pdf'
  end

  test do
    system 'qualimap', '-h'
  end
end
