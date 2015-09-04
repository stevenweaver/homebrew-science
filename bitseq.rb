class Bitseq < Formula
  homepage "https://code.google.com/p/bitseq/"
  url "https://bitseq.googlecode.com/files/BitSeq-0.4.3.tar.gz"
  sha1 "603feb5fccdd95d496c27fe78e7f1f81e46bc1ed"

  needs :openmp

  def install
    system "make"
    bin.install "convertSamples",
                "estimateDE",
                "estimateExpression",
                "estimateHyperPar",
                "extractSamples",
                "getFoldChange",
                "getGeneExpression",
                "getPPLR",
                "getVariance",
                "getWithinGeneExpression",
                "parseAlignment",
                "transposeLargeFile"
  end

  test do
    system "#{bin}/parseAlignment", "--help"
  end
end
