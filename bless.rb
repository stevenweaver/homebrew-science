class Bless < Formula
  homepage "https://sourceforge.net/projects/bless-ec/"
  # doi "10.1093/bioinformatics/btu030"
  # tag "bioinformatics"

  url "https://downloads.sourceforge.net/project/bless-ec/bless.v0p24.tgz"
  version "0.24"
  sha1 "95082ceda46ea01ee6b8caa10718de00901a04de"

  bottle do
    cellar :any
    sha1 "e5a148a6174d4958e212155c94d7333f08ee997f" => :mountain_lion
  end

  needs :openmp

  depends_on "boost"
  depends_on "google-sparsehash" => :build
  depends_on "kmc" => :recommended
  depends_on :mpi

  def install
    # Do not build vendored dependency, kmc.
    inreplace "Makefile", "cd kmc; make CC=$(CC)", ""

    system "make"
    bin.install "bless"
    doc.install "README", "LICENSE"
  end

  test do
    system "#{bin}/bless"
  end
end
