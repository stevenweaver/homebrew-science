class Biobloomtools < Formula
  desc "BioBloom Tools (BBT): Bloom filter for bioinformatics"
  homepage "http://www.bcgsc.ca/platform/bioinfo/software/biobloomtools/"
  # doi "10.1093/bioinformatics/btu558"
  # tag "bioinformatics"

  url "https://github.com/bcgsc/biobloom/releases/download/2.0.12/biobloomtools-2.0.12.tar.gz"
  sha256 "13053036ca4a23032a7fb201bf22862187e4d8f584c3b1f6440d829210954a3e"

  head do
    url "https://github.com/bcgsc/biobloom.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  bottle do
    cellar :any
    sha256 "68c125cd6e5e02b1eb2aa79e40ca6e82c2bb2ed8764f6d11445463fb460032d4" => :yosemite
    sha256 "fcf60aca3e3326a1a422535190de56d2c8dc1d26af1cd1320f642485db7fe64c" => :mavericks
    sha256 "0730a556dc8b5cbc99f653ab8eeb4de922875ca3b23113b9103cf42406ec6a43" => :mountain_lion
  end

  depends_on "boost" => :build

  def install
    system "./autogen.sh" if build.head?
    system "./configure",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--prefix=#{prefix}"
    system "make", "install"
    doc.install "README.html", "README.md"
  end

  test do
    system "#{bin}/biobloommaker", "--version"
    system "#{bin}/biobloomcategorizer", "--version"
  end
end
