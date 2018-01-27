require 'open-uri'
require 'openssl'
require 'nokogiri'
require 'mechanize'
require 'pathname'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

agent = Mechanize.new
url = "https://search.yahoo.co.jp/image/search?p=" + ARGV[0].to_s
page = agent.get(url)

# googleでappleを検索した結果ページのリンクを一式取得
page.links.each do |link|
  p link.text
  p link.href
end


p page
class FileDownloader
  attr_reader :doc
  
  def initialize(url)
    @doc = Nokogiri::HTML(open(url,&:read))
  end
  
  #HTMLからpng/jpgファイルのリストを取得
  def fetch_img_url_list
    img_list = Array.new
    
    @doc.css('a img').each do |img|
        p img['src']
    img_list << img['src']
    end
    
    img_list
  end

  
  #png/jpgのリストからファイルをローカルにダウンロード
  def write_url(url_list,dest_dir)
    dir = Pathname.new(dest_dir)
    #FileUtils.dir.rmdir if dir.exist?
    dir.mkdir unless dir.exist?

    i = 1;
    #書き出す場所を指定
    url_list.each do |url|
    if i > ARGV[1].to_i then
        break
    end
    #書き出す場所を指定
    filename = File.basename(url)
    dest = open(dest_dir + i.to_s + ".png", 'wb') rescue next
    file = open(url) rescue next
    dest.write(file.read)

    i = i + 1
    end
  end  
end

downloader = FileDownloader.new(page.uri.to_s)
list = downloader.fetch_img_url_list
file_dir = "./image/"
unless ARGV[2].to_s.empty? then
    file_dir = ARGV[2].to_s
end
downloader.write_url(list,file_dir)

