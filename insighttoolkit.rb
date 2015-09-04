class Insighttoolkit < Formula
  desc "ITK is a toolkit for performing registration and segmentation"
  homepage "http://www.itk.org"
  url "https://downloads.sourceforge.net/project/itk/itk/4.8/InsightToolkit-4.8.0.tar.gz"
  sha256 "8de5081f81707faf0cddd42f7eeea9498ce790672eb382a0d72b153623dca08a"
  head "git://itk.org/ITK.git"

  bottle do
    sha256 "4395012e9362f42884f8e26dc57d769fb618da03fa358ab37cef0b9b91bbf17f" => :yosemite
    sha256 "e0ee511f1c24f638d9acfd1420c2f55c9a13491022bfede24ed33857bdd596b6" => :mavericks
    sha256 "74e2efe52e51b10f6a2fd8be35cf7e065c11d7a971462dfa15bc7676b507ac20" => :mountain_lion
  end

  option :cxx11
  cxx11dep = (build.cxx11?) ? ["c++11"] : []

  depends_on "cmake" => :build
  depends_on "vtk" => [:build] + cxx11dep
  depends_on "opencv" => [:optional] + cxx11dep
  depends_on :python => :optional
  depends_on "fftw" => :recommended
  depends_on "hdf5" => [:recommended] + cxx11dep
  depends_on "jpeg" => :recommended
  depends_on "libpng" => :recommended
  depends_on "libtiff" => :recommended
  depends_on "gdcm" => [:optional] + cxx11dep

  deprecated_option "examples" => "with-examples"
  deprecated_option "remove-legacy" => "with-remove-legacy"

  option "with-examples", "Compile and install various examples"
  option "with-itkv3-compatibility", "Include ITKv3 compatibility"
  option "with-remove-legacy", "Disable legacy APIs"

  def install
    args = std_cmake_args + %W[
      -DBUILD_TESTING=OFF
      -DBUILD_SHARED_LIBS=ON
      -DITK_USE_GPU=ON
      -DITK_USE_64BITS_IDS=ON
      -DITK_USE_STRICT_CONCEPT_CHECKING=ON
      -DITK_USE_SYSTEM_ZLIB=ON
      -DCMAKE_INSTALL_RPATH:STRING=#{lib}
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{lib}
      -DModule_ITKLevelSetsv4Visualization=ON
      -DModule_SCIFIO=ON
      -DModule_ITKReview=ON
    ]
    args << ".."
    args << "-DBUILD_EXAMPLES=" + ((build.include? "examples") ? "ON" : "OFF")
    args << "-DModule_ITKVideoBridgeOpenCV=" + ((build.with? "opencv") ? "ON" : "OFF")
    args << "-DITKV3_COMPATIBILITY:BOOL=" + ((build.with? "itkv3-compatibility") ? "ON" : "OFF")

    args << "-DITK_USE_SYSTEM_FFTW=ON" << "-DITK_USE_FFTWF=ON" << "-DITK_USE_FFTWD=ON" if build.with? "fftw"
    args << "-DITK_USE_SYSTEM_HDF5=ON" if build.with? "hdf5"
    args << "-DITK_USE_SYSTEM_JPEG=ON" if build.with? "jpeg"
    args << "-DITK_USE_SYSTEM_PNG=ON" if build.with? :libpng
    args << "-DITK_USE_SYSTEM_TIFF=ON" if build.with? "libtiff"
    args << "-DITK_USE_SYSTEM_GDCM=ON" if build.with? "gdcm"
    args << "-DITK_LEGACY_REMOVE=ON" if build.include? "remove-legacy"

    args << "-DVCL_INCLUDE_CXX_0X=ON" if build.cxx11?
    ENV.cxx11 if build.cxx11?

    mkdir "itk-build" do
      if build.with? "python"
        args += %W[
          -DITK_WRAP_PYTHON=ON
          -DModule_ITKVtkGlue=ON
        ]
        # CMake picks up the system's python dylib, even if we have a brewed one.
        args << "-DPYTHON_LIBRARY='#{%x(python-config --prefix).chomp}/lib/libpython2.7.dylib'"
        args << "-DPYTHON_INCLUDE_DIR='#{%x(python-config --prefix).chomp}/include/python2.7'"
      end
      system "cmake", *args
      system "make", "install"
    end
  end
end
