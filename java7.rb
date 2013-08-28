require 'formula'

DMG = 'jdk-7u10-ea-bin-b08-macosx-x86_64-20_sep_2012.dmg'
PKG = '/Volumes/JDK 7 Update 10/JDK 7 Update 10.pkg'

class Java7< Formula

  homepage 'http://jdk7.java.net/download.html'
  url "http://packages.livefyre.com/buildout/packages/#{DMG}"
  version 'jdk1.7.0_10'
  sha1 '52a50cdcd48c02cab3d036291ed73ca82f0e63a9'

  def install
    jvm_home = "/Library/Java/JavaVirtualMachines/#{version}.jdk/Contents/Home"
    system "open", DMG
    sleep(10)
    system "open", PKG
    bin.install_symlink Dir["#{libexec}/bin/*"]
    (bin/'java7_home').write <<-EOS.undent
      #!/bin/bash
      echo /Library/Java/JavaVirtualMachines/#{version}.jdk/Contents/Home
    EOS
    (bin/'java7').write <<-EOS.undent
      #!/bin/bash
      JAVA_HOME=/Library/Java/JavaVirtualMachines/#{version}.jdk/Contents/Home
      PATH=$JAVA_HOME:$PATH
      exec $*
    EOS
    (bin/'mvn_j7').write <<-EOS.undent
      #!/bin/bash
      JAVA_HOME=/Library/Java/JavaVirtualMachines/#{version}.jdk/Contents/Home
      MAVEN_HOME
      M2
      PATH=$JAVA_HOME:$PATH
      exec $*
    EOS
  end

  def caveats; <<-EOS.undent
    You need to click through the package installer.

    The package will install under:
        /Library/Java/JavaVirtualMachines/#{version}.jdk/
    EOS
  end
end
