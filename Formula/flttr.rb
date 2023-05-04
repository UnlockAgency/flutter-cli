class Flttr < Formula
    desc "An Unlock wrapper for Flutter"
    homepage "https://github.com/troovers/homebrew-flttr"
    url "https://github.com/troovers/homebrew-flttr.git"
        # or tag: "1_0_release", revision: "090930930295adslfknsdfsdaffnasd13"
        # or revision: "090930930295adslfknsdfsdaffnasd13"

    version "0.1.0"
    
    def install
        bin.install "RUBYLIB=lib bin/flttr"
    end
  
    test do
        system "false"
    end
end