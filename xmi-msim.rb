class XmiMsim < Formula
  homepage "https://github.com/tschoonj/xmimsim"
  url "http://lvserver.ugent.be/xmi-msim/xmimsim-5.0.tar.gz"
  mirror "https://xmi-msim.s3.amazonaws.com/xmimsim-5.0.tar.gz"
  sha1 "cb8f83fe594f8808079d64dfd7e592c710891efc"
  revision 1

  bottle do
    sha256 "20d513767c84fdce79035995a1c944baa502c8902d9ada3e5936b21b7634b2c2" => :yosemite
    sha256 "256f4aacfda4a9ce1e86a6c568c9f8fee0fe6e88ed93b18ae1ae86356fe5a83d" => :mavericks
    sha256 "1761c9e032b189f30309a6afdb46f4883a3e06e49818a5a8164a7b098d6babf9" => :mountain_lion
  end

  depends_on :fortran
  depends_on "gsl"
  depends_on "fgsl"
  depends_on "libxml2"
  depends_on "libxslt"
  depends_on "glib"
  depends_on "hdf5"
  depends_on "pkg-config" => :build
  depends_on "xraylib" => "with-fortran"
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  patch do
    url "https://github.com/tschoonj/xmimsim/commit/682ff5b413fc326c1cc8e9931d34bce3e920c798.diff"
    sha1 "8881ee02307b85a0032373191de1a07104a37d8c"
  end

  def install
    ENV.deparallelize  # fortran modules don't like parallel builds

    system "autoreconf", "-i"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-gui",
                          "--disable-updater",
                          "--disable-mac-integration",
                          "--disable-libnotify",
                          "--enable-opencl"
    system "make"

    # this next step can take a long time...
    system "./bin/xmimsim-db"
    system "make", "install"
    (share / "xmimsim").install "xmimsimdata.h5"
  end

  test do
    system "#{bin}/xmimsim", "--version"
  end
end
