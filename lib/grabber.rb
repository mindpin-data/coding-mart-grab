module CodingMart
  class Grabber
    def initialize(id)
      @id = id
    end

    def page_url
      "https://mart.coding.net/project/#{@id}?#{rand}"
    end

    def get_html
      uri = URI self.page_url
      res = Net::HTTP.get_response uri
    end

    def save
      puts "正在抓取： #{@id}, #{self.page_url}"
      res = self.get_html
      html = res.body

      mp = MartPage.where(page_id: @id).first_or_create
      mp.page_html = html
      mp.save
      puts "保存完毕： #{@id}"
    rescue
      puts "保存失败： #{@id}"
    end
  end
end