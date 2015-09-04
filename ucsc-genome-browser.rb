class UcscGenomeBrowser < Formula
  desc "A mirror of the UCSC Genome Browser"
  homepage "http://genome.ucsc.edu"
  # doi "10.1093/nar/gkq963"
  # tag "bioinformatics"

  url "http://hgdownload.cse.ucsc.edu/admin/jksrc.v316.zip"
  sha256 "8ad7d11c776c52abc69557f393cb0df38c79efc8875a1f0652928ca0e8240f72"
  head "git://genome-source.cse.ucsc.edu/kent.git"

  keg_only <<-EOF.undent
    The UCSC Genome Browser installs many commands, and some conflict
    with other packages.
  EOF

  depends_on "libpng"
  depends_on :mysql
  depends_on "openssl"

  def install
    ENV.j1
    machtype = `uname -m`.chomp
    user = `whoami`.chomp
    mkdir prefix/"cgi-bin-#{user}"
    mkdir prefix/"htdocs-#{user}"
    cd "src/lib" do
      system "make", "MACHTYPE=#{machtype}"
    end
    cd "src/jkOwnLib" do
      system "make", "MACHTYPE=#{machtype}"
    end
    cd "src" do
      system "make",
        "MACHTYPE=#{machtype}",
        "BINDIR=#{bin}",
        "SCRIPTS=#{prefix}/scripts",
        "CGI_BIN=#{prefix}/cgi-bin",
        "DOCUMENTROOT=#{prefix}/htdocs",
        "PNGLIB=-L#{Formula["libpng"].opt_lib} -lpng",
        "MYSQLLIBS=-lmysqlclient -lz",
        "MYSQLINC=#{Formula["mysql"].opt_include}/mysql"
    end
    mv "#{prefix}/cgi-bin-#{user}", prefix/"cgi-bin"
    mv "#{prefix}/htdocs-#{user}", prefix/"htdocs"
  end

  # TODO: Best would be if this formula would put a complete working
  #       apache virtual site into #{share} and instruct the user to just
  #       do a symlink.
  def caveats; <<-EOF.undent
      To complete the installation of the UCSC Genome Browser, follow
      these instructions:
        http://genomewiki.ucsc.edu/index.php/Browser_Installation

      To complete a minimal installation, follow these directions:

      # Configure the Apache web server.
      # Warning! This command will overwrite your existing web site.
      # HELP us to improve these instructions so that a new virtual site is created.

      rsync -avzP rsync://hgdownload.cse.ucsc.edu/htdocs/ /Library/WebServer/Documents/
      sudo cp -a #{prefix}/cgi-bin/* /Library/WebServer/CGI-Executables/
      sudo mkdir /Library/WebServer/CGI-Executables/trash
      sudo wget https://gist.github.com/raw/4626128 -O /Library/WebServer/CGI-Executables/hg.conf
      mkdir /usr/local/apache
      ln -s /Library/WebServer/Documents /usr/local/apache/htdocs
      sudo apachectl start

      # Configure the MySQL database.
      cd #{HOMEBREW_PREFIX}/opt/mysql && mysqld_safe &
      mysql -uroot -proot -e "create user 'hguser'@'localhost' identified by 'hguser';"
      rsync -avzP rsync://hgdownload.cse.ucsc.edu/mysql/hgcentral/ #{HOMEBREW_PREFIX}/var/mysql/hgcentral/
      mysql -uroot -proot -e "grant all privileges on hgcentral.* to 'hguser'@'localhost'"
      mysql -uroot -proot -e "create database hgFixed"
      mysql -uroot -proot -e "grant select on hgFixed.* to 'hguser'@'localhost'"

      Point your browser to http://localhost/cgi-bin/hgGateway
    EOF
  end

  test do
    (testpath/"test.fa").write <<-EOF.undent
      >test
      ACTG
    EOF
    system "#{bin}/faOneRecord test.fa test > out.fa"
    compare_file "test.fa", "out.fa"
  end
end
