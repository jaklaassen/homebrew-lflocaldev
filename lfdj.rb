require 'formula'

class Lfdj < Formula
  homepage 'http://github.com/Livefyre/lfdj'
  #head 'git@github.com:Livefyre/lfdj.git'
  url 'https://raw.github.com/gist/7181e7f98f07ca234595/e81cb0a56c2e82cf88efe77dcb49ee4028193c5b/supervisord.conf'
  version '1.0'
  depends_on 'libevent'
  depends_on 'lfpython'
  depends_on 'lfservices'

  def install
    prefix.mkpath
    (var + 'log/lfdj').mkpath
    (bin + 'refresh_mysql_db').write <<-EOS.undent
      #!/bin/bash -ex
      cd #{ENV['HOME']}/dev/lfdj/lfcore
      supervisorctl stop sv:* || true
      mysql -uroot -p12345 -e "drop database if exists lfdj;" 
      mysql -uroot -p12345 -e "CREATE DATABASE lfdj char set utf8;" 
      mysql -uroot -p12345 lfdj < lfcore/domain/sql/domain.sql
      bin/django syncdb --noinput
    EOS
    (bin + 'refresh_mongo_db').write <<-EOS.undent
      #!/bin/bash -ex
      mongo --eval "var dbs = db.getMongo().getDBNames().filter(function (x) { return x.indexOf('lfdj_') == 0}); for (var i in dbs) { db = db.getMongo().getDB(dbs[i]); print('dropping db ' + db.getName() ); db.dropDatabase(); }"
    EOS
    (bin + 'refresh_es').write <<-EOS.undent
      #!/bin/bash -ex
      cd #{ENV['HOME']}/dev/lfdj/lfdrone
      for c in comment user conv; do
        bin/django rebuild_search_indices --index=$c --verbose --no-prompt
      done
      MIN_ID=`mysql -uroot -p12345 lfdj -e "select min(id) from activity_onconv \\G" | grep min | sed -e 's/.*: //'`
      bin/django update_search_activity_id --reset=$MIN_ID
    EOS
    (bin + 'refresh_all').write <<-EOS.undent
      #!/bin/bash -ex
      redis-cli flushdb
      #{bin}/refresh_bs_s3
      #{bin}/refresh_mongo_db
      #{bin}/refresh_mysql_db
      #{bin}/refresh_es
    EOS
    (bin + 'refresh_bs_s3').write <<-EOS.undent
      #!/bin/bash -ex
      echo "assert settings.BOOTSTRAP_S3_SETTINGS['prefix'] == '$USER'; from lfcore.v2.fulfillment.util import S3Api; S3Api().empty_bucket(settings.BOOTSTRAP_S3_SETTINGS['bucket_name'], settings.BOOTSTRAP_S3_SETTINGS['prefix'])" | $HOME/dev/lfdj/lfdrone/bin/django shell_plus
    EOS
    (bin + 'lfuse').write <<-EOS.undent
      #!/bin/bash
      
      usage="$0 <localhost|c4.livefyre.com|t500.livefyre.com|...>"
      p=$HOME/dev/lfdev/scripts/lfclustercfg
      my=$HOME/.livefyre/my.cfg
      out=$HOME/.livefyre/cluster.cfg
      case "$1" in
        "localhost")
           echo "Updating local cluster.cfg to point to localhost..."
           $p $out $HOME/dev/lfdev/conf/cluster.cfg.local_dev $my
           supervisorctl start services:*
           echo now: supervisorctl restart sv:*
           ;;
        "")
           echo $usage; exit 1;;
        *)
           echo "Updating local cluster.cfg to point to $1..."
           $p --tunnel=$1 $out $HOME/dev/lfdev/conf/cluster.cfg.tunnel $my
           supervisorctl stop services:*
           supervisorctl start tunnel
           echo now: supervisorctl restart sv:*
           ;;
      esac
    EOS
  end
end
