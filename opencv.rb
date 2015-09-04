class Opencv < Formula
  desc "Open source computer vision library"
  homepage "http://opencv.org/"
  url "https://github.com/Itseez/opencv/archive/2.4.12.tar.gz"
  sha256 "8989f946a66fa3fc2764d637b1c866caf28d074ece187f86baba66544054eefc"
  head "https://github.com/Itseez/opencv.git", :branch => "2.4"

  bottle do
    sha256 "c61e0ff1a122459eea44bea04df13592ebbbd67bb3097e07d45217aae85e1947" => :yosemite
    sha256 "bab6a64b65a2800f0bceefb1d32729b618ddde8dfc1f82ec0e066c1ff68aed54" => :mavericks
    sha256 "38d298cf40f733c6d6e1b647442a1c355cc478ced24105325b879ab70b3324d0" => :mountain_lion
  end

  option "32-bit"
  option "with-java", "Build with Java support"
  option "with-qt", "Build the Qt4 backend to HighGUI"
  option "with-tbb", "Enable parallel code in OpenCV using Intel TBB"
  option "without-tests", "Build without accuracy & performance tests"
  option "without-opencl", "Disable GPU code in OpenCV using OpenCL"
  option "with-cuda", "Build with CUDA support"
  option "with-quicktime", "Use QuickTime for Video I/O instead of QTKit"
  option "with-opengl", "Build with OpenGL support"
  option "with-ximea", "Build with XIMEA support"
  option "without-numpy", "Use a numpy you've installed yourself instead of a Homebrew-packaged numpy"
  option "without-python", "Build without Python support"

  deprecated_option "without-brewed-numpy" => "without-numpy"

  option :cxx11

  depends_on :ant if build.with? "java"
  depends_on "cmake"      => :build
  depends_on "eigen"      => :recommended
  depends_on "gstreamer"  => :optional
  depends_on "gst-plugins-good" if build.with? "gstreamer"
  depends_on "jasper"     => :optional
  depends_on :java        => :optional
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "libdc1394"  => :optional
  depends_on "openexr"    => :recommended
  depends_on "openni"     => :optional
  depends_on "pkg-config" => :build
  depends_on "qt"         => :optional
  depends_on "tbb"        => :optional

  depends_on :python => :recommended unless OS.mac? && MacOS.version > :snow_leopard
  depends_on "homebrew/python/numpy" => :recommended if build.with? "python"

  # Can also depend on ffmpeg, but this pulls in a lot of extra stuff that
  # you don't need unless you're doing video analysis, and some of it isn't
  # in Homebrew anyway. Will depend on openexr if it's installed.
  depends_on "ffmpeg" => :optional

  def arg_switch(opt)
    (build.with? opt) ? "ON" : "OFF"
  end

  def install
    ENV.cxx11 if build.cxx11?
    jpeg = Formula["jpeg"]
    dylib = OS.mac? ? "dylib" : "so"

    args = std_cmake_args + %W[
      -DCMAKE_OSX_DEPLOYMENT_TARGET=
      -DBUILD_ZLIB=OFF
      -DBUILD_TIFF=OFF
      -DBUILD_PNG=OFF
      -DBUILD_OPENEXR=OFF
      -DBUILD_JASPER=OFF
      -DBUILD_JPEG=OFF
      -DJPEG_INCLUDE_DIR=#{jpeg.opt_include}
      -DJPEG_LIBRARY=#{jpeg.opt_lib}/libjpeg.#{dylib}
    ]
    args << "-DBUILD_TESTS=OFF" << "-DBUILD_PERF_TESTS=OFF" if build.without? "tests"
    args << "-DBUILD_opencv_python=" + arg_switch("python")
    args << "-DBUILD_opencv_java=" + arg_switch("java")
    args << "-DWITH_OPENEXR="   + arg_switch("openexr")
    args << "-DWITH_EIGEN="     + arg_switch("eigen")
    args << "-DWITH_TBB="       + arg_switch("tbb")
    args << "-DWITH_FFMPEG="    + arg_switch("ffmpeg")
    args << "-DWITH_QUICKTIME=" + arg_switch("quicktime")
    args << "-DWITH_1394="      + arg_switch("libdc1394")
    args << "-DWITH_OPENGL="    + arg_switch("opengl")
    args << "-DWITH_JASPER="    + arg_switch("jasper")
    args << "-DWITH_QT="        + arg_switch("qt")
    args << "-DWITH_GSTREAMER=" + arg_switch("gstreamer")
    args << "-DWITH_XIMEA="     + arg_switch("ximea")

    if build.with? "python"
      py_prefix = `python-config --prefix`.chomp
      py_lib = OS.linux? ? `python-config --configdir`.chomp : "#{py_prefix}/lib"
      args << "-DPYTHON_LIBRARY=#{py_lib}/libpython2.7.#{dylib}"
      args << "-DPYTHON_INCLUDE_DIR=#{py_prefix}/include/python2.7"
      # Make sure find_program locates system Python
      # https://github.com/Homebrew/homebrew-science/issues/2302
      args << "-DCMAKE_PREFIX_PATH=#{py_prefix}" if OS.mac?
    end

    if build.with? "cuda"
      ENV["CUDA_NVCC_FLAGS"] = "-Xcompiler -stdlib=libstdc++; -Xlinker -stdlib=libstdc++"
      args << "-DWITH_CUDA=ON"
      args << "-DCMAKE_CXX_FLAGS=-stdlib=libstdc++"
      args << "-DCUDA_GENERATION=Kepler"
    else
      args << "-DWITH_CUDA=OFF"
    end

    # OpenCL 1.1 is required, but Snow Leopard and older come with 1.0
    args << "-DWITH_OPENCL=OFF" if build.without?("opencl") || MacOS.version < :lion

    if build.with? "openni"
      args << "-DWITH_OPENNI=ON"
      # Set proper path for Homebrew's openni
      inreplace "cmake/OpenCVFindOpenNI.cmake" do |s|
        s.gsub! "/usr/include/ni", "#{Formula["openni"].opt_include}/ni"
        s.gsub! "/usr/lib", "#{Formula["openni"].opt_lib}"
      end
    end

    if build.include? "32-bit"
      args << "-DCMAKE_OSX_ARCHITECTURES=i386"
      args << "-DOPENCV_EXTRA_C_FLAGS='-arch i386 -m32'"
      args << "-DOPENCV_EXTRA_CXX_FLAGS='-arch i386 -m32'"
    end

    if ENV.compiler == :clang && !build.bottle?
      args << "-DENABLE_SSSE3=ON" if Hardware::CPU.ssse3?
      args << "-DENABLE_SSE41=ON" if Hardware::CPU.sse4?
      args << "-DENABLE_SSE42=ON" if Hardware::CPU.sse4_2?
      args << "-DENABLE_AVX=ON" if Hardware::CPU.avx?
    end

    mkdir "macbuild" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <opencv/cv.h>
      #include <iostream>
      int main()
      {
        std::cout << CV_VERSION << std::endl;
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-L#{lib}", "-o", "test"
    assert_equal `./test`.strip, version.to_s
  end
end
