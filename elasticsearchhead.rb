require 'formula'

class Elasticsearchhead < Formula
  homepage 'https://github.com/mobz/elasticsearch-head'
  url 'https://raw.github.com/gist/7181e7f98f07ca234595/e81cb0a56c2e82cf88efe77dcb49ee4028193c5b/supervisord.conf'
  depends_on 'elasticsearch'
  version '0.19.9' # there's no way to make this Elasticsearch.new.version

  def install
    v = Elasticsearch.new.version
    if version != v
      onoe "version=#{version} does not match es version=#{v}"
      exit 1
    end
    system "/usr/local/Cellar/elasticsearch/#{v}/bin/plugin -install mobz/elasticsearch-head"
    (prefix + 'totem').write ""
  end
end
