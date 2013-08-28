require 'formula'

class Lfwebjs < Formula
  homepage 'http://github.com/Livefyre/lfwebjs'
  #head 'git@github.com:Livefyre/lfdj.git'
  url 'https://raw.github.com/gist/7181e7f98f07ca234595/e81cb0a56c2e82cf88efe77dcb49ee4028193c5b/supervisord.conf'
  version '1.0'
  depends_on 'plovr'
  depends_on 'supervisord'
  depends_on 'lfpython'
  depends_on 'lfservices'

  def install
    dir = (etc + 'sconf.lfwebjs')
    dir.mkpath
    (dir + 'proxy.conf').write proxy
    (dir + 'conv_plovr_raw.conf').write conv_plovr_raw
    (dir + 'conv_plovr_dev.conf').write conv_plovr_dev
    (dir + 'servers.conf').write servers
    (dir + 'conv_asset_server.conf').write conv_asset_server
    (dir + 'conv_sample_server.conf').write conv_sample_server
    (dir + 'admin_asset_server.conf').write admin_asset_server
    (dir + 'group.conf').write program_group
    share.install dir
  end

  def program_group
    return <<-EOS
[group:proxy]
programs=proxy
priority=500

[group:widget]
programs=conv_plovr_raw,conv_asset_server,conv_sample_server
priority=500

[group:widget_alts]
programs=conv_plovr_dev
priority=500

[group:admin]
programs=admin_asset_server
priority=500

[group:sv]
programs=bootstrap,admin,search,write
priority=999
    EOS
  end

  # Adds lfadmin at port 11110
  # Adds lfbootstrap at port 11111
  # Adds lfsearch at port 11112
  # Adds lfwrite at port 11113
  # !! Sync with https://github.com/Livefyre/lfdev/blob/master/proxy/proxy.js
  def servers
    a = []
    ['admin', 'bootstrap', 'search', 'write'].each_with_index do |pn, i|
      a.push <<-EOS.undent
        [program:#{pn}]
        command = /usr/local/bin/python #{ENV['HOME']}/dev/lfdj/lf#{pn}/bin/django run_gunicorn --bind=127.0.0.1:1111#{i}
        redirect_stderr=True
        process_name = #{pn}
        directory = #{ENV['HOME']}/dev/lfdj/lf#{pn}
        priority = 999
        autorestart = false
        autostart = false
        stopsignal=KILL
        killasgroup=true
        user = #{ENV['USER']}
        environment = USER=#{ENV['USER']}
      EOS
    end
    return a.join("\n")
  end

  def proxy
    return <<-EOS
[program:proxy]
command = #{HOMEBREW_PREFIX}/bin/node proxy.js
directory = #{ENV['HOME']}/dev/lfdev/proxy
process_name = proxy
priority = 500
autorestart = true
autostart = true
startsecs = 5
startretries = 10
environment = PATH="#{HOMEBREW_PREFIX}/share/npm/bin:$PATH"
    EOS
  end

  def conv_plovr_raw
    return <<-EOS
[program:conv_plovr_raw]
command = #{HOMEBREW_PREFIX}/bin/plovr serve --port 9111 #{ENV['HOME']}/dev/lfwebjs/lfconv/parts/plovr/plovr.raw.js
process_name = conv_plovr_raw
directory = #{var}
priority = 500
autorestart = true
autostart = true
startsecs = 5
startretries = 10
user = #{ENV['USER']}
    EOS
  end

  def conv_plovr_dev
    return <<-EOS
[program:conv_plovr_dev]
command = #{HOMEBREW_PREFIX}/bin/plovr serve --port 9111 #{ENV['HOME']}/dev/lfwebjs/lfconv/parts/plovr/plovr.dev.js
process_name = conv_plovr_dev
directory = #{var}
priority = 500
autorestart = false
autostart = false
startsecs = 5
startretries = 10
user = #{ENV['USER']}
    EOS
  end

  def conv_sample_server
    return <<-EOS
[program:conv_sample_server]
command = python -m SimpleHTTPServer 9113
process_name = conv_sample_server
directory = #{ENV['HOME']}/dev/lfwebjs/lfconv/samples
priority = 500
autorestart = true
autostart = true
startsecs = 5
startretries = 10
user = #{ENV['USER']}
    EOS
  end

  def conv_asset_server
    return <<-EOS
[program:conv_asset_server]
command = #{ENV['HOME']}/dev/lfwebjs/lfconv/bin/asset_server 9112
process_name = conv_asset_server
directory = #{var}
priority = 500
autorestart = true
autostart = true
startsecs = 5
startretries = 10
user = #{ENV['USER']}
    EOS
  end

  def admin_asset_server
    return <<-EOS
[program:admin_asset_server]
command = #{ENV['HOME']}/dev/lfwebjs/lfadmin/bin/asset_server 9101
process_name = admin_asset_server
directory = #{var}
priority = 500
autorestart = true
autostart = true
startsecs = 5
startretries = 10
user = #{ENV['USER']}
    EOS
  end

end
