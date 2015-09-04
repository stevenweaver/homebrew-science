class Dssp < Formula
  homepage "http://swift.cmbi.ru.nl/gv/dssp/"
  url "https://mirrors.kernel.org/debian/pool/main/d/dssp/dssp_2.2.1.orig.tar.gz"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/d/dssp/dssp_2.2.1.orig.tar.gz"
  sha256 "5fb5e7c085de16c05981e3a72869c8b082911a0b46e6dcc6dbd669c9f267e8e1"

  bottle do
    sha256 "d24eda9478670b24b40b27dac9ef9f31034c3f6ab2007900f4a972ec1208a0fd" => :yosemite
    sha256 "66276ea7fa9226c2cf0a901231d7b9cd79ca806f402ef865b201ecea83c19597" => :mavericks
    sha256 "f904611240d8959d7ebe0694da2a10fdb7bbaeb6c317f90f441bd449373e539c" => :mountain_lion
  end

  depends_on "boost"

  resource "pdb" do
    url "ftp://ftp.cmbi.ru.nl/pub/molbio/data/pdb_redo/zz/3zzz/3zzz_0cyc.pdb.gz"
    sha256 "6ee5ab16972d8f3ae6c2f92fce789a40fecb1a6a8c0de42257b35fc7e9d82149"
  end

  def install
    # Create a make.config file that contains the configuration for boost
    boost = Formula["boost"].opt_prefix
    File.open("make.config", "w") do |makeconf|
      makeconf.puts "BOOST_LIB_SUFFIX = -mt"
      makeconf.puts "BOOST_LIB_DIR = #{boost}/lib"
      makeconf.puts "BOOST_INC_DIR = #{boost}/include"
    end

    # There is no need for the build to be static and static build causes
    # an error: ld: library not found for -lcrt0.o
    inreplace "makefile" do |s|
      s.gsub!(/-static/, "")
    end

    system "make", "install", "DEST_DIR=#{prefix}", "MAN_DIR=#{man1}"
  end

  test do
    resource("pdb").stage do
      system bin/"mkdssp", "-i", "3zzz_0cyc.pdb",
             "-o", testpath/"test.dssp"
    end
    assert_match "POLYPYRIMIDINE TRACT BINDING PROTEIN RRM2",
                 (testpath/"test.dssp").read
  end
end
