require 'formula'

class RabbitmqHa < Formula
  homepage 'https://github.com/jaklaassen/rabbitmq-ha-client'
  url 'https://github.com/jaklaassen/rabbitmq-ha-client.git'
  version '0.2.0-SNAPSHOT'

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
