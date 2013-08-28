require 'formula'

class Lfstream < Formula
  homepage 'http://github.com/Livefyre/perseids'
  url 'http://packages.livefyre.com/buildout/packages/osx/perseids-1.0.0-Alpha1.zip'
  version '1.0.0-Alpha1'
  depends_on 'supervisord'
  depends_on 'lfpython'
  depends_on 'lfservices'

  def install
    dir = (prefix + 'sconf.lfstream')
    dir.mkpath
    (dir + 'servers.conf').write servers
    (dir + 'group.conf').write program_group
    libexec.install Dir["*.jar", "*.xml"]
    share.install dir
    (bin + 'runserver').write <<-EOS.undent
      #!/bin/bash
      dev_root=#{ENV['HOME']}/dev/perseids
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
        -Dperseids.returnAddr=redis://127.0.0.1:6378/0 \
        -Dperseids.redisQueueHost=redis://127.0.0.1:6379/0 \
        -Dperseids.redisLivecountHost=redis://127.0.0.1:6379/0 \
        -Dperseids.numWorkers=1 \
        -Dperseids.statsdAddr=statsd://107.23.16.37:8125 \
        -Dperseids.statsdPrefix=`hostname | sed -e 's/\./-/'` \
        -Dlogback.configurationFile=#{libexec}/logback.xml \
        -cp #{libexec}/perseids-#{version}-jar-with-dependencies.jar \
         com.livefyre.perseids.server.Run
    EOS
  end

  def program_group
    return <<-EOS
[group:stream]
programs=ct,mq2,mq
priority=500
    EOS
  end

  def servers
    return <<-EOS
[program:ct]
command = #{bin}/runserver
redirect_stderr=True
process_name = ct
directory = #{prefix}
priority = 999
autorestart = false
autostart = false
stopsignal = KILL
killasgroup = true
user = #{ENV['USER']}
environment = USER=#{ENV['USER']}

[program:mq2]
command = #{ENV['HOME']}/dev/lfdj/lfbootstrap/bin/django run_mqueue_v2 --workers=1 --reqlimit=100000 --disable-wal
redirect_stderr=True
process_name = mq2
directory = #{ENV['HOME']}/dev/lfdj/lfbootstrap
priority = 999
autorestart = false
autostart = false
stopsignal = KILL
killasgroup = true
user = #{ENV['USER']}
environment = USER=#{ENV['USER']}

[program:mq]
command = #{ENV['HOME']}/dev/lfdj/lfbootstrap/bin/django run_mqueue --workers=1 --reqlimit=100000 --disable-wal --redishost=localhost
redirect_stderr=True
process_name = mq
directory = #{ENV['HOME']}/dev/lfdj/lfbootstrap
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
