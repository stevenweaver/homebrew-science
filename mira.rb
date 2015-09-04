require 'formula'

class Mira < Formula
  homepage 'http://sourceforge.net/projects/mira-assembler'
  #doi "10.1101/gr.1917404"
  #tag "bioinformatics"

  url 'https://downloads.sourceforge.net/project/mira-assembler/MIRA/stable/mira-4.0.2.tar.bz2'
  sha1 '30db5cb9e9e1c1848b2f24a169ce5bc7948845b3'

  depends_on 'boost'
  depends_on 'google-perftools' => :recommended # for tcmalloc
  depends_on 'docbook'
  # On Xcode-only systems, Mira's configure is unable to find expat
  depends_on 'expat'
  # FlexLexer.h is not in the 10.8 SDK (only in 10.7 SDK and in xctoolchain/usr/include)
  # Further, an ugly patch would be needed to work with OS X's flex (on 10.8)
  # http://www.freelists.org/post/mira_talk/Type-mismatch-of-LexerInput-and-LexerOutput-PATCH
  depends_on 'flex'

  fails_with :clang
  fails_with :llvm
  fails_with :gcc
  fails_with :gcc => '4.5' do
    cause 'gcc >= 4.6 is required to compile MIRA.'
  end

  def install
    configure_args = ["--disable-debug",
                      "--disable-dependency-tracking",
                      "--prefix=#{prefix}",
                      "--with-expat=#{Formula["expat"].opt_prefix}",
                      "--with-expat-lib=-L#{Formula["expat"].opt_prefix}/lib",
                      "--with-boost=#{Formula["boost"].opt_prefix}",
                      "--with-boost-libdir=#{Formula["boost"].opt_prefix}/lib",
                      "--with-boost-regex=boost_regex-mt",
                      "--with-boost-system=boost_system-mt",
                      "--with-boost-filesystem=boost_filesystem-mt",
                      "--with-boost-iostreams=boost_iostreams-mt"]
    configure_args += ["--with-tcmalloc",
      "--with-tcmalloc-dir=#{Formula["google-perftools"].opt_prefix}/lib"] if build.with?("google-perftools")

    system "./configure", *configure_args

    # Link with boost_system for boost::system::system_category().
    # http://www.freelists.org/post/mira_talk/Linking-requires-boost-system
    make_args = ["LIBS='-lboost_regex-mt -lboost_system-mt -lboost_filesystem-mt -lboost_iostreams-mt -lboost_thread-mt -lexpat -lz'"]
    system "make", *make_args
    system "make", "check"
    system "make", "install"
  end

  test do
    system "#{bin}/mira --version"
  end
end
