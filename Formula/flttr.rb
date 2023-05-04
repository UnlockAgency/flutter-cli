class Flttr < Formula
    desc "An Unlock wrapper for Flutter"
    homepage "https://github.com/troovers/homebrew-flttr"
    url "https://github.com/troovers/homebrew-flttr.git"
    version: "0.1.0"
    
    def install
        bin.install "bin/flttr"
    end
  
    test do
        system "false"
    end
end