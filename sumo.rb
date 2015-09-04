class Sumo < Formula
  homepage "https://sourceforge.net/projects/sumo/"
  url "https://downloads.sourceforge.net/project/sumo/sumo/version%200.23.0/sumo-all-0.23.0.tar.gz"
  sha256 "8a6354a11717cdff2f3f247239fb55472ea57268b392e5e442777a1c05d92299"

  bottle do
    cellar :any
    sha256 "fc42a513a71d13b54d230ac0bc26cbc96a0aa2323ee434c4313ef28e4e1f3217" => :yosemite
    sha256 "13ab2b7e6d904ee4009162a7a8a3c6038d3aec2a48c4407a5093b5aa729ab9e4" => :mavericks
    sha256 "4b2e04b94e1a95cc5759d422402b34c9534cbc8873911038fe41a2ee0fbc271d" => :mountain_lion
  end

  option "with-check", "Enable additional build-time checking"

  depends_on :x11
  depends_on "xerces-c"
  depends_on "libpng"
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "proj"
  depends_on "gdal"
  depends_on "fox"
  depends_on :python

  resource "gtest" do
    url "https://googletest.googlecode.com/files/gtest-1.7.0.zip"
    sha256 "247ca18dd83f53deb1328be17e4b1be31514cedfc1e3424f672bf11fd7e0d60d"
  end

  resource "TextTest" do
    url "https://pypi.python.org/packages/source/T/TextTest/TextTest-3.28.tar.gz"
    sha256 "700e9648c193fd29796af7df6074a306224f99d1837966433d612abce08ca47a"
  end

  def install
    resource("gtest").stage do
      system "./configure"
      system "make"
      buildpath.install "../gtest-1.7.0"
    end

    ENV["LDFLAGS"] = "-lpython"  # My compilation fails without this flag, despite :python dependency.
    ENV.append_to_cflags "-I#{buildpath}/gtest-1.7.0/include"

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-python",
                          "--with-gtest-config=gtest-1.7.0/scripts/gtest-config"

    system "make", "install"

    # Basic tests, they are fast, so execute them always.
    system "unittest/src/sumo-unittest"

    # Additional tests. These take more time, and some fail on my machine...
    if build.with? "check"
      ENV.prepend_create_path "PYTHONPATH", buildpath/"vendor/lib/python2.7/site-packages"
      resource("TextTest").stage { Language::Python.setup_install "python", buildpath/"vendor" }
      ENV.prepend_create_path "PATH", buildpath/"vendor/bin"
      system "tests/runTests.sh", "-l", "-zen", "-b", "homebrew-compilation-check"
    end
  end

  def caveats; <<-EOS.undent
    Some SUMO scripts require SUMO_HOME environmental variable:
      export SUMO_HOME=#{prefix}
    EOS
  end

  test do
    # A simple hand-made test to see if sumo compiled and linked well.

    (testpath/"hello.nod.xml").write <<-EOS.undent
      <nodes>
          <node id="1" x="-250.0" y="0.0" />
          <node id="2" x="+250.0" y="0.0" />
          <node id="3" x="+251.0" y="0.0" />
      </nodes>
    EOS

    (testpath/"hello.edg.xml").write <<-EOS.undent
      <edges>
          <edge from="1" id="1to2" to="2" />
          <edge from="2" id="out" to="3" />
      </edges>
    EOS

    system "#{bin}/netconvert", "--node-files=#{testpath}/hello.nod.xml", "--edge-files=#{testpath}/hello.edg.xml", "--output-file=#{testpath}/hello.net.xml"

    (testpath/"hello.rou.xml").write <<-EOS.undent
      <routes>
          <vType accel="1.0" decel="5.0" id="Car" length="2.0" maxSpeed="100.0" sigma="0.0" />
          <route id="route0" edges="1to2 out"/>
          <vehicle depart="1" id="veh0" route="route0" type="Car" />
      </routes>
    EOS

    (testpath/"hello.sumocfg").write <<-EOS.undent
      <configuration>
          <input>
              <net-file value="hello.net.xml"/>
              <route-files value="hello.rou.xml"/>
          </input>
          <time>
              <begin value="0"/>
              <end value="10000"/>
          </time>
      </configuration>
    EOS

    system "#{bin}/sumo", "-c", "hello.sumocfg"
  end
end
