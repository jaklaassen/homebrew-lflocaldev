require 'formula'

class Lflivecount < Formula
  homepage 'http://github.com/Livefyre/livecount'
  url 'http://packages.livefyre.com/buildout/packages/osx/livecount-1.0.0-Alpha1.zip'
  version '1.0.0-Alpha1'
  depends_on 'supervisord'

  def install
    dir = (prefix + 'sconf.lflc')
    dir.mkpath
    (dir + 'servers.conf').write servers
    (dir + 'group.conf').write program_group
    share.install dir
    libexec.install Dir["*.jar", "*.xml"]
    (bin + 'runlc').write <<-EOS.undent
      #!/bin/bash
      export LIVECOUNT_PORT=10199
      dev_root=#{ENV['HOME']}/dev/livecount
      dev_script=bin/runserver.sh
      if [ -e "$dev_root/$dev_script" ]; then
         echo "Using development version"
         cd $dev_root
         exec $dev_script
         exit 0
      fi
      echo "Using packaged jar"
      exec java -server \
        -XX:+UseBiasedLocking -XX:+AggressiveOpts -XX:+UseFastAccessorMethods -XX:+HeapDumpOnOutOfMemoryError \
        -Dlivecount.redis=redis://127.0.0.1:6379/0 \
        -Dlivecount.statsdAddr=statsd://107.23.16.37:8125 \
        -Dlivecount.basePort=$LIVECOUNT_PORT \
        -Dlivecount.statsdPrefix=`hostname | sed -e 's/\./-/'` \
        -Dlogback.configurationFile=#{libexec}/logback.xml \
        -cp #{libexec}/livecount-#{version}-jar-with-dependencies.jar \
         com.livefyre.livecount.server.Run
    EOS
  end

  def program_group
    return <<-EOS
[group:lc]
programs=lcs
priority=500
    EOS
  end

  def servers
    return <<-EOS
[program:lcs]
command = #{bin}/runlc
redirect_stderr=True
process_name = lcs
directory = #{var}/log
priority = 999
autorestart = false
autostart = false
stopsignal = KILL
killasgroup = true
user = #{ENV['USER']}
environment = USER=#{ENV['USER']}
    EOS
  end
end
