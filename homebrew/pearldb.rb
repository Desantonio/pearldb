cat <<EOF > homebrew/pearldb.rb
class Pearldb < Formula
  desc "Lightweight pure-Perl SQL-like database"
  homepage "https://github.com/Desantonio/pearldb"
  url "https://github.com/Desantonio/pearldb/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "<REPLACE_WITH_ACTUAL_SHA256>"
  license "MIT"

  depends_on "perl"

  def install
    bin.install "bin/pearldb"
    prefix.install Dir["lib", "test", "share"]
  end

  test do
    output = shell_output("#{bin}/pearldb --help", 1)
    assert_match "PearlDB", output
  end
end
EOF
