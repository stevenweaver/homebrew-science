require "formula"

class Tisean < Formula
  homepage "http://www.mpipks-dresden.mpg.de/~tisean/"
  url "http://www.mpipks-dresden.mpg.de/~tisean/TISEAN_3.0.1.tar.gz"
  sha1 "7fe71899b063abe1b3d9aae88f153988495d623b"
  revision 2

  bottle do
    cellar :any
    sha256 "7f371b4adb10c1f3b9ac5899aecda52d05f5667941aa419422b8874305bfea67" => :yosemite
    sha256 "0e67267ae5ee08fe0855d670577e02585884f6851bf8f1fa3f1d469d32f0a197" => :mavericks
    sha256 "205942c3e368a65fdf3d255fef32bc8933fec2ba7266d93eec7b618937fdb299" => :mountain_lion
  end

  option "without-prefixed-binaries", "Do not prefix binaries with `tisean-`"

  depends_on :fortran
  depends_on "gnu-sed"

  BINS = ["poincare", "extrema", "rescale", "recurr", "corr", "mutual",
          "false_nearest", "lyap_r", "lyap_k", "lyap_spec", "d2", "av-d2",
          "makenoise", "nrlazy", "low121", "lzo-test", "lfo-run", "lfo-test",
          "rbf", "polynom", "polyback", "polynomp", "polypar", "ar-model",
          "mem_spec", "pca", "ghkss", "lfo-ar", "xzero", "xcor", "boxcount",
          "fsle", "resample", "histogram", "nstat_z", "sav_gol", "delay",
          "lzo-gm", "arima-model", "lzo-run", "c1", "c2naive", "xc2", "c2d",
          "c2g", "c2t", "pc", "predict", "stp", "lazy", "project", "addnoise",
          "compare", "upo", "upoembed", "cluster", "choose", "rms", "notch",
          "autocor", "spectrum", "wiener1", "wiener2", "surrogates",
          "endtoend", "timerev", "events", "intervals", "spikespec",
          "spikeauto", "henon", "ikeda", "lorenz", "ar-run", "xrecur"]

  def install
    system "./configure", "--prefix=#{prefix}"
    inreplace "./source_f/Makefile", "sed", "gsed"
    inreplace "./source_f/cluster.f",
              "999  if(iv_io(iverb).eq.1) write(0,'(a,i)') \"matrix size \", np",
              "999  if(iv_io(iverb).eq.1) write(0,*) \"matrix size \", np"
    bin.mkpath
    system "make"
    system "make", "install"
    if build.with? "prefixed-binaries"
      Tisean::BINS.each { |item| system "mv #{bin}/#{item} #{bin}/tisean-#{item}" }
    end
  end

  def caveats
    if build.with? "prefixed-binaries" then <<-EOS.undent
      By default, all TISEAN binaries are prefixed with `tisean-`.
      For unprefixed binaries, use `--without-prefixed-binaries`.
      EOS
    end
  end

  test do
    pfx = build.with?("prefixed-binaries") ? "tisean-" : ""
    Tisean::BINS.each { |item| system "#{bin}/#{pfx}#{item} -h" }
  end
end
