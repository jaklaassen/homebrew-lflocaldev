require 'formula'

class VoomVertx < Formula
  homepage 'https://github.com/jaklaassen/voom-vertx'
  url 'https://github.com/jaklaassen/voom-vertx.git'
  version '1.2.1-SNAPSHOT'
  depends_on "vert.x"
  depends_on "voom-java"
  depends_on "rabbitmq-ha"

  def install
    system "mvn install"
  end

  def test
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test vert.x`.
    #system "false"
  end
end
