require 'formula'

class Distribute < Formula
  url 'http://pypi.python.org/packages/source/d/distribute/distribute-0.6.28.tar.gz'
  sha1 '709bd97d46050d69865d4b588c7707768dfe6711'
end

class Buildout < Formula
  url 'http://pypi.python.org/packages/source/z/zc.buildout/zc.buildout-1.5.2.tar.gz'
  md5 '87f7b3f8d13926c806242fd5f6fe36f7'
end

class Genshi < Formula
  url 'http://ftp.edgewall.com/pub/genshi/Genshi-0.6.tar.gz'
  md5 '604e8b23b4697655d36a69c2d8ef7187'
end

class MySQLPython < Formula
  url 'http://pypi.python.org/packages/source/M/MySQL-python/MySQL-python-1.2.3.tar.gz'
  md5 '215eddb6d853f6f4be5b4afc4154292f'
end

class Lfpython< Formula
  depends_on 'python'
  depends_on 'pil'
  depends_on 'protobuf'

  homepage 'http://github.com/Livefyre/lfdj'
  #head 'git@github.com:Livefyre/lfdj.git'
  url 'https://raw.github.com/gist/7181e7f98f07ca234595/e81cb0a56c2e82cf88efe77dcb49ee4028193c5b/supervisord.conf'
  version '1.1'

  def python_share
    return Pathname.new('/usr/local/share/python')
  end

  def local_bin
    return Pathname.new('/usr/local/bin')
  end

  def install
    ENV.prepend 'PATH', python_share, ':'
    ENV.prepend 'PATH', local_bin, ':'
    [MySQLPython, Genshi, Distribute, Buildout].each do |m|
      m.new.brew do
        system "python", "setup.py", "build_ext"
        system 'python', 'setup.py', 'install'
      # system "easy_install", "--script-dir=#{HOMEBREW_PREFIX}/share/python", m.url
      end
    end
    (prefix + "totem").write ""
  end
end
