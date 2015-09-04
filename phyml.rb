class Phyml < Formula
  desc "Fast maximum likelihood-based phylogenetic inference"
  bottle do
    cellar :any
    sha256 "ccae08800290289e8989d6da5aab65adb6cded93e6a32b284f184a7c372f947b" => :yosemite
    sha256 "c8cc4b9434128305c7a759a73e67f28dc3a4418531be80694ab80a06786e770d" => :mavericks
    sha256 "723aa3d01acf9ec3b4fc4aa8ed48abd0db5208abb9c7f8e23c5549e6668a29b5" => :mountain_lion
  end

  # tag "bioinformatics"
  # doi "10.1093/sysbio/syq010"
  homepage "http://www.atgc-montpellier.fr/phyml/"
  url "https://phyml.googlecode.com/files/phyml-20120412.tar.gz"
  sha256 "a43e51534a1ae2d1ee4c94ced3a1855813ff4872a6c9c2b83b369ddb71198417"

  def install
    # separate steps required
    system "./configure", "--prefix=#{prefix}"
    system "make"

    system "./configure", "--prefix=#{prefix}", "--enable-phytime"
    system "make"

    bin.install "src/phyml", "src/phytime"
    doc.install "doc/phyml-manual.pdf"
    pkgshare.install Dir["examples/*"]
  end

  def caveats; <<-EOS.undent
    Examples have been installed here:
      #{opt_pkgshare}

    See options for phyml by running:
      phmyl --help

    PhyML must be run with the "-i" option to specify an input or it will
    segfault. Example:
      phyml -i #{opt_pkgshare}/nucleic
    EOS
  end
end
