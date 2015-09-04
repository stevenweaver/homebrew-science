class Plink < Formula
  homepage "http://pngu.mgh.harvard.edu/~purcell/plink/"
  url "http://pngu.mgh.harvard.edu/~purcell/plink/dist/plink-1.07-src.zip"
  sha256 "4af56348443d0c6a1db64950a071b1fcb49cc74154875a7b43cccb4b6a7f482b"
  # tag "bioinformatics"
  # doi "10.1086/519795"

  bottle do
    cellar :any
    sha256 "e9aae1de18b36eb1b9fa200a9ec4527af50e14df9b1ae245bd983eb592920250" => :yosemite
    sha256 "b123ad9ffbc9825aece2080ce51ca6814c8a5821dcee5b865b328b24917332f7" => :mavericks
    sha256 "e0b9b89dff5335544012f7592cfa72cfddc44ee33b6809c9a16c02343df7fa4e" => :mountain_lion
  end

  # allows plink to build with clang and new versions of gcc
  # borrowed from Debian; discussion at:
  # https://lists.debian.org/debian-mentors/2012/04/msg00410.html
  patch :DATA

  # plink delays in some circumstances due to webcheck timeout
  # build option to skip webcheck
  option "without-webcheck", "Build without default version webcheck"

  def install
    make_args = (OS.mac?) ? ["SYS=MAC"] : ["FORCE_DYNAMIC=1"]
    make_args << "WITH_WEBCHECK=0" if build.without? "webcheck"
    system "make", *make_args
    (share / "plink").install "test.map", "test.ped"
    bin.install "plink"
    doc.install "COPYING.txt", "README.txt"
  end

  test do
    system "plink", "--file", prefix/"share/plink/test"
  end
end
__END__
diff --git a/elf.cpp b/elf.cpp
index ec2ed3d..49bda44 100644
--- a/elf.cpp
+++ b/elf.cpp
@@ -1175,10 +1175,10 @@ void Plink::elfBaseline()
 	  << setw(8) << gcnt << " "
 	  << setw(8) << (double)cnt / (double)gcnt << "\n";
 
-      map<int,int>::iterator i = chr_cnt.begin();
-      while ( i != chr_cnt.end() )
+      map<int,int>::iterator i_iter = chr_cnt.begin();
+      while ( i_iter != chr_cnt.end() )
 	{
-	  int c = i->first;
+	  int c = i_iter->first;
 	  int x = chr_cnt.find( c )->second;
 	  int y = chr_gcnt.find( c )->second;
 	  
@@ -1189,7 +1189,7 @@ void Plink::elfBaseline()
 	      << setw(8) << y << " "
 	      << setw(8) << (double)x / (double)y << "\n";
 	  
-	  ++i;
+	  ++i_iter;
 	}
       
     }
diff --git a/idhelp.cpp b/idhelp.cpp
index a9244fa..8353c9e 100644
--- a/idhelp.cpp
+++ b/idhelp.cpp
@@ -772,12 +772,12 @@ void IDHelper::idHelp()
       for (int j = 0 ; j < jointField.size(); j++ )
 	{
 	  set<IDField*> & jf = jointField[j];
-	  set<IDField*>::iterator j = jf.begin();
+	  set<IDField*>::iterator j_iter = jf.begin();
 	  PP->printLOG(" { ");
-	  while ( j != jf.end() )
+	  while ( j_iter != jf.end() )
 	    {
-	      PP->printLOG( (*j)->name + " " );
-	      ++j;
+	      PP->printLOG( (*j_iter)->name + " " );
+	      ++j_iter;
 	    }
 	  PP->printLOG(" }");
 	}
diff --git a/sets.cpp b/sets.cpp
index 3a8f92f..adef60f 100644
--- a/sets.cpp
+++ b/sets.cpp
@@ -768,11 +768,11 @@ vector_t Set::profileTestScore()
       //////////////////////////////////////////////
       // Reset original missing status
 
-      vector<Individual*>::iterator i = PP->sample.begin();
-      while ( i != PP->sample.end() )
+      vector<Individual*>::iterator i_iter = PP->sample.begin();
+      while ( i_iter != PP->sample.end() )
 	{
-	  (*i)->missing = (*i)->flag;
-	  ++i;
+	  (*i_iter)->missing = (*i_iter)->flag;
+	  ++i_iter;
 	}
 
       ////////////////////////////////////////////////
