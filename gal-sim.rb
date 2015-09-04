class GalSim < Formula
  desc "A modular galaxy image simulation toolkit"
  homepage "https://github.com/GalSim-developers/GalSim"
  url "https://github.com/GalSim-developers/GalSim/archive/v1.3.0.tar.gz"
  sha256 "4afd3284adfd12845b045ea3c8e293b63057c7da57872bc9eecd005cf0a763c0"
  head "https://github.com/GalSim-developers/GalSim.git"

  depends_on "scons" => :build
  depends_on "fftw"
  depends_on "boost"
  depends_on "boost-python"
  depends_on "tmv-cpp"

  # pyfits should come from pip
  depends_on "pyfits" => :python
  depends_on "numpy" => :python

  option "with-openmp", "Enable openmp support (gcc only)"

  def pyver
    IO.popen("python -c 'import sys; print sys.version[:3]'").read.strip
  end

  def install
    args = []
    if build.with? "openmp"
      if ENV.compiler == :clang
        opoo "OpenMP support will not be enabled. Use --cc=gcc-x.y if you require OpenMP."
      end
      args << "WITH_OPENMP=true"
    end
    scons *args
    scons "install", "PREFIX=#{prefix}", "PYPREFIX=#{lib}/python#{pyver}"
  end

  def caveats; <<-EOS.undent
    The GalSim installer may warn you that #{lib}/python isn't in your python
    search path. You may want to add all Homebrew python packages to the
    default paths by running:
       sudo bash -c 'echo \"/usr/local/lib/python\" >> \\\\
         /Library/Python/#{pyver}/site-packages/homebrew.pth'
    EOS
  end
end
