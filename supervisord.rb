require 'formula'

class Supervisord < Formula
  depends_on 'python'

  url 'http://pypi.python.org/packages/source/s/supervisor/supervisor-3.0b1.tar.gz'
  md5 '5a2f1bb052bb2bbfd6d69ba8b1e1dad7'

  def python_share
    return Pathname.new('/usr/local/share/python')
  end 

  def install
    unless python_share.directory?
      print "Expecting the brew install python to be found at: #{python_share}"
      exit -1
    end

    ENV.prepend 'PATH', python_share, ':'
    (share + 'supervisord.conf').write supervisord_conf
    (etc + 'supervisor/conf.d').mkpath
    (var + 'log/livefyre').mkpath
    system "python", "setup.py", "install"
  end

  def caveats
    bn = plist_path.basename
    la = Pathname.new("Library/LaunchDaemons")
    prettypath = "/Library/LaunchDaemons/#{bn}"
    domain = plist_path.basename('.plist')
    load = "launchctl load -w #{prettypath}"
    s = []

    # we readlink because this path probably doesn't exist since caveats
    # occurs before the link step of installation
    if not (la/bn).file?
      s << "To have launchd start #{name} at login:"
      s << "    sudo cp #{plist_path} /Library/LaunchDaemons/#{bn}"
      s << "Then to load #{name} now:"
      s << "    sudo #{load}"
    elsif Kernel.system "/bin/launchctl list #{domain} &>/dev/null"
      s << "You should reload #{name}:"
      s << "    sudo launchctl unload -w #{prettypath}"
      s << "    sudo #{load}"
    else
      s << "To load #{name}:"
      s << "    sudo #{load}"
    end
  end

  def plist
    return <<-EOPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>#{plist_name}</string>
  <key>ProgramArguments</key>
  <array>
    <string>#{python_share}/supervisord</string>
    <string>--configuration=#{share}/supervisord.conf</string>
    <string>-n</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>UserName</key>
  <string>root</string>
  <key>WorkingDirectory</key>
  <string>#{HOMEBREW_PREFIX}</string>
  <key>StandardErrorPath</key>
  <string>#{var}/log/supervisord-output.log</string>
  <key>StandardOutPath</key>
  <string>#{var}/log/supervisord-error.log</string>
</dict>
</plist>
EOPLIST
  end

  def supervisord_conf; <<-EOS.undent
    [supervisord]
    childlogdir = #{var}/log/livefyre
    logfile = #{var}/log/supervisord.log
    logfile_maxbytes = 50MB
    logfile_backups = 1
    loglevel = info
    pidfile = #{var}/supervisord.pid
    umask = 022
    nodaemon = false
    nocleanup = false
    
    [inet_http_server]
    port = 127.0.0.1:9001
    username = 
    password = 
    
    [supervisorctl]
    serverurl = http://127.0.0.1:9001
    username = 
    password = 

    [rpcinterface:supervisor]
    supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface

    [include]
    files=#{etc}/supervisor/conf.d/*.conf #{HOMEBREW_PREFIX}/share/sconf.*/*.conf
    EOS
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end
end
