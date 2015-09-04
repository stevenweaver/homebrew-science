class RstudioServer < Formula
  homepage "http://www.rstudio.com"
  url "https://github.com/rstudio/rstudio/archive/v0.99.473.tar.gz"
  sha256 "a402995251393d50fa70e2e02188a8b32dc34e067f2f8461f087bf71f643585c"

  bottle do
    sha256 "ce5defab059bdc9452c007e94772d957594688bed899061b4fe6f10864ec2c3e" => :yosemite
    sha256 "d6da8dd62a9e94705b14890bbc6932f9abe4ac745578d368c54cc2d783636819" => :mavericks
    sha256 "fe343ba1961d3ba11ab86597084e180de97edea88cf1d2c4470b269a3225b2ff" => :mountain_lion
  end

  depends_on "ant" => :build
  depends_on "cmake" => :build
  depends_on "homebrew/versions/boost150" => :build
  depends_on "r"
  depends_on "openssl"

  resource "gin" do
    url "https://s3.amazonaws.com/rstudio-buildtools/gin-1.5.zip"
    sha256 "f561f4eb5d5fe1cff95c881e6aed53a86e9f0de8a52863295a8600375f96ab94"
  end

  resource "gwt" do
    url "https://s3.amazonaws.com/rstudio-buildtools/gwt-2.7.0.zip"
    sha256 "aa65061b73836190410720bea422eb8e787680d7bc0c2b244ae6c9a0d24747b3"
  end

  resource "junit" do
    url "https://s3.amazonaws.com/rstudio-buildtools/junit-4.9b3.jar"
    sha256 "dc566c3f5da446defe36c534f7ee19cdfe7e565020038b2ef38f01bc9c070551"
  end

  resource "selenium" do
    url "https://s3.amazonaws.com/rstudio-buildtools/selenium-java-2.37.0.zip"
    sha256 "0eebba65d8edb01c1f46e462907c58f5d6e1cb0ddf63660a9985c8432bdffbb7"
  end

  resource "selenium-server" do
    url "https://s3.amazonaws.com/rstudio-buildtools/selenium-server-standalone-2.37.0.jar"
    sha256 "97bc8c699037fb6e99ba7af570fb60dbb1b7ce30cde2448287a44ef65b13023e"
  end

  resource "chromedriver-mac" do
    url "https://s3.amazonaws.com/rstudio-buildtools/chromedriver-mac"
    sha256 "5bf42fd9bcc45d45b54a0f59d5839feb454f39fd14170b8fab7f59bf59b1af64"
  end

  resource "pandoc" do
    url "https://s3.amazonaws.com/rstudio-buildtools/pandoc-1.13.1.zip"
    sha256 "7aedb183913f46cc7e5fd35098e5ed275c5436da0a0f82d5d56c057fd27caf5f"
  end

  resource "dictionaries" do
    url "https://s3.amazonaws.com/rstudio-dictionaries/core-dictionaries.zip"
    sha256 "4341a9630efb9dcf7f215c324136407f3b3d6003e1c96f2e5e1f9f14d5787494"
  end

  resource "mathjax" do
    url "https://s3.amazonaws.com/rstudio-buildtools/mathjax-23.zip"
    sha256 "5242d35eb5f0d6fae295422b39a61070c17f9a7923e6bc996c74b9a825c1d699"
  end

  resource "libclang" do
    url "https://s3.amazonaws.com/rstudio-buildtools/libclang-3.5.zip"
    sha256 "ecb06fb65ddf0eb7c04be28edd11cc38717102afbe4dbfd6e237ea58d1da85ea"
  end

  resource "libclang-builtin-headers" do
    url "https://s3.amazonaws.com/rstudio-buildtools/libclang-builtin-headers.zip"
    sha256 "0b8f54c8d278dd5cd2fb3ec6f43e9ea1bfc9e8d595ff88127073d46550e88a74"
  end

  resource "rsconnect" do
    url "https://github.com/rstudio/rsconnect.git", :branch => "v0.99"
  end

  def install
    # installation path of boost is hard coded, it has to be changed manually.
    inreplace "src/cpp/CMakeLists.txt",
      "/opt/rstudio-tools/boost/boost_1_50_0",
      "#{Formula["boost150"].opt_prefix}"

    gwt_lib = buildpath/"src/gwt/lib/"
    (gwt_lib/"gin/1.5").install resource("gin")
    (gwt_lib/"gwt/2.7.0").install resource("gwt")
    gwt_lib.install resource("junit")
    (gwt_lib/"selenium/2.37.0").install resource("selenium")
    (gwt_lib/"selenium/2.37.0").install resource("selenium-server")
    (gwt_lib/"selenium/chromedriver/2.7").install resource("chromedriver-mac")

    common_dir = buildpath/"dependencies/common"

    resource("pandoc").stage do
      (common_dir/"pandoc/1.13.1/").install "mac/pandoc"
      (common_dir/"pandoc/1.13.1/").install "mac/pandoc-citeproc"
    end

    (common_dir/"dictionaries").install resource("dictionaries")
    (common_dir/"mathjax-23").install resource("mathjax")

    resource("libclang").stage do
      (common_dir/"libclang/3.5/").install "mac/x86_64/libclang.dylib"
    end

    (common_dir/"libclang/builtin-headers").install resource("libclang-builtin-headers")

    (common_dir/"rsconnect").install resource("rsconnect")
    chdir("dependencies/common") { system "R", "CMD", "build", "rsconnect" }

    mkdir "build" do
      system "cmake", "..",
        "-DRSTUDIO_TARGET=Server",
        "-DCMAKE_BUILD_TYPE=Release",
        "-DBOOST_ROOT=#{Formula["boost150"].opt_prefix}",
        "-DBoost_INCLUDE_DIR=#{Formula["boost150"].opt_prefix}/include",
        "-DCMAKE_INSTALL_PREFIX=#{prefix}/rstudio"
      system "make", "install"
    end

    (bin/"rstudio-server").write <<-EOS.undent
      #!/usr/bin/env bash

      export PATH=#{opt_prefix}/rstudio/bin:$PATH
      export PATH=#{opt_prefix}/rstudio/bin/pandoc:$PATH
      export PATH=#{opt_prefix}/rstudio/bin/postback:$PATH

      #{opt_prefix}/rstudio/bin/rserver "$@"
    EOS
  end

  test do
    system "rstudio-server", "--help"
  end
end
