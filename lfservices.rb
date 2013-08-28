require 'formula'

class Lfservices < Formula
  homepage 'http://github.com/Livefyre/lfdj'
  #head 'git@github.com:Livefyre/lfdj.git'
  url 'https://raw.github.com/gist/7181e7f98f07ca234595/e81cb0a56c2e82cf88efe77dcb49ee4028193c5b/supervisord.conf'
  version '1.1.2'
  depends_on 'cmake'
  depends_on 'mysql'
  depends_on 'mongodb'
  depends_on 'redis'
  depends_on 'elasticsearch'
  depends_on 'elasticsearchhead'
  depends_on 'supervisord'
  depends_on 'selenium-server-standalone'
  depends_on 'rabbitmq'

  def install
    dir = (prefix + 'sconf.lfservices')
    dir.mkpath
    (dir + 'es.conf').write elasticsearch
    (dir + 'redis.conf').write redis
    (dir + 'mongo.conf').write mongo
    (dir + 'mysql.conf').write mysql
    (dir + 'rabbit.conf').write rabbit
    (dir + 'selenium.conf').write selenium
    (dir + 'group.conf').write program_group
    share.install dir
  end

  def program_group
    return <<-EOS
[group:services]
programs=mysql,mongo,redis,elasticsearch,rabbit
priority=1
    EOS
  end

  def selenium
    v = SeleniumServerStandalone.new.version
    return <<-EOS
[program:selenium]
command = /usr/bin/java -jar /usr/local/Cellar/selenium-server-standalone/#{v}/selenium-server-standalone-#{v}.jar -port 4444
process_name = selenium
directory = /usr/local/var
priority = 5
autorestart = false
autostart = false
startsecs = 5
startretries = 10
user = #{ENV['USER']}
    EOS
  end

  def mysql
    hoststr = `hostname`.strip
    return <<-EOS
[program:mysql]
command = /usr/local/share/python/pidproxy /usr/local/var/mysql/#{hoststr}.pid /usr/local/bin/mysqld_safe
process_name = mysql
directory = /usr/local/var
priority = 5
autorestart = true
startsecs = 5
startretries = 10
user = #{ENV['USER']}
    EOS
  end

  def mongo
    return <<-EOS
[program:mongo]
command = /usr/local/opt/mongodb/mongod run --config /usr/local/etc/mongod.conf
process_name = mongo
directory = /usr/local/var
priority = 5
autorestart = true
startsecs = 5
startretries = 10
user = #{ENV['USER']}
    EOS
  end

  def redis
    return <<-EOS
[program:redis]
command = /usr/local/bin/redis-server /usr/local/etc/redis.conf
process_name = redis
directory = /usr/local/var
priority = 5
autorestart = true
startsecs = 5
startretries = 10
user = #{ENV['USER']}
    EOS
  end

  def rabbit
    hoststr = `hostname`.strip
    return <<-EOS
[program:rabbit]
command = /usr/local/opt/rabbitmq/sbin/rabbitmq-server
process_name = rabbit
directory = /usr/local/var
priority = 5
autorestart = true
startsecs = 5
startretries = 10
user = #{ENV['USER']}
environment = PATH=/usr/local/sbin:/usr/bin:/bin:/usr/local/bin,CONF_ENV_FILE=/usr/local/etc/rabbitmq/rabbitmq-env.conf,HOME=#{ENV['HOME']}
    EOS
  end


  def elasticsearch
    v = Elasticsearch.new.version
    return <<-EOS
[program:elasticsearch]
command = /usr/local/bin/elasticsearch -f -D es.config=/usr/local/Cellar/elasticsearch/#{v}/config/elasticsearch.yml
process_name = elasticsearch
directory = /usr/local/var
priority = 5
autorestart = true
startsecs = 5
startretries = 10
environment=ES_JAVA_OPTS=-Xss200000
user = #{ENV['USER']}
    EOS
  end
end
