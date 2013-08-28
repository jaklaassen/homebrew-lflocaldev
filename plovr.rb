require 'formula'

class Plovr < Formula
  homepage 'http://plovr.com'
  url 'http://plovr.googlecode.com/files/plovr-4b3caf2b7d84.jar'
  sha1 '4b5c1f9b6ec4f4c27cd0af5201e3d2dc44f04c09'
  version '4b3caf2b7d84'

  def install
    libexec.install "plovr-#{version}.jar"
    (bin+'plovr').write <<-EOS.undent
      #!/bin/sh
      exec java -jar "#{libexec}/plovr-#{version}.jar" "$@"
    EOS
  end
end
