class EvWorker < Formula
  desc 'ev ci worker node'
  homepage 'http://artifactory.evf.us/artifactory'
  url 'http://artifactory.evf.us/artifactory/automation-tools/bundles/ev-worker/1.17.0.pre1/package-170111164203.tar.gz'
  sha256 'ff14ba4f3d0d04270cb8b3b834f101141bca5ac42789156c7ef10fc8406f8601'
  version '1.17.0.pre1'

  def install
    ENV.deparallelize
    libexec.install Dir['*']
    inreplace "#{libexec}/vendor/install/bin/ev-worker", 'pushd $APP_ROOT', "pushd #{libexec}"
    bin.install_symlink Dir["#{libexec}/vendor/install/bin/*"]
    etc.install_symlink Dir["#{libexec}/config/app.yaml.example"]
  end

  def post_install
    (var/'log').mkpath
    (var/'log/ev-worker').mkpath
  end

  def caveats; <<-EOS.undent
    To configure ev ci worker node, copy the example configuration to #{etc}/ev-worker.yaml
    and edit to taste.

      $ cp #{etc}/app.yaml.example #{etc}/ev-worker.yaml

    In order to run worker manually execute the following:

      $ ev-worker -c #{etc}/ev-worker.yaml -l #{var}/log/ev-worker/access.log

    Make sure "Virtual Box" and "Vagrant" are installed on your system.
  EOS
  end

  plist_options :startup => true

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>WorkingDirectory</key>
      <string>#{libexec}</string>
      <key>Nice</key>
      <integer>-14</integer>
      <key>ProgramArguments</key>
      <array>
        <string>#{bin}/ev-worker</string>
        <string>-c</string>
        <string>#{etc}/ev-worker.yaml</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
      <key>ServiceDescription</key>
      <string>ev ci worker node</string>
      <key>Debug</key>
      <true/>
      <key>StandardErrorPath</key>
      <string>#{var}/log/ev-worker/stderr.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/ev-worker/stdout.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    system "#{bin}/ev-worker --test"
  end
end
