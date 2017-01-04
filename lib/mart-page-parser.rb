module CodingMart
  class MartPageParser1
    def initialize(id)
      @id = id
      @page = MartPage.where(page_id: id).first
      @doc = Nokogiri::HTML @page.page_html
    end

    # 是否无效页面
    def is_404
      @doc.css('title').text.include? '404'
    end

    def _parse_brief
      title     = @doc.css('.reward-title .title-row .title').text.strip
      status    = @doc.css('.reward-title .title-row .status').text.strip

      reward_no = @doc.css('.reward-title .desc-row .role-type .reward-no').text.strip
      _doc_roles     = @doc.css('.reward-title .desc-row .role-type span:not(.reward-no)')
      roles = _doc_roles.map {|x| x.text.strip}

      money     = @doc.css('.reward-title .detail-row .detail-span:nth-child(1)').children[-1].text.strip
      type      = @doc.css('.reward-title .detail-row .detail-span:nth-child(2)').children[-1].text.strip
      period    = @doc.css('.reward-title .detail-row .detail-span:nth-child(3)').children[-1].text.strip

      negotiable = @doc.css('.reward-title .detail-row .negotiable').text.strip
      diamond = @doc.css('.diamond-ribbon').length > 0

      _doc_re = @doc.css('.reward-evaluation')
      e1 = _doc_re.css('.evaluation-item[data-type="1"] .evaluation-count').text.strip
      e2 = _doc_re.css('.evaluation-item[data-type="2"]  .evaluation-count').text.strip
      e3 = _doc_re.css('.evaluation-item[data-type="3"]  .evaluation-count').text.strip
      e4 = _doc_re.css('.evaluation-item[data-type="4"]  .evaluation-count').text.strip

      _match = @doc.css('.reward-apply').text.strip.match(/\d+/)
      reward_apply = _match.nil? ? '' : _match[0]

      {
        title: title,
        status: status,
        desc: {
          reward_no: reward_no,
          roles: roles
        },
        detail: {
          money: money,
          type: type,
          period: period,
          negotiable: negotiable,
          diamond: diamond,
        },
        evaluation: {
          too_little_money: e1,
          tight: e2,
          do_not_fly: e3,
          will_not_do: e4
        },
        reward_apply: reward_apply
      }
    end

    # 解析有效页面
    def parse
      brief = self._parse_brief


      _doc_groups = @doc.css('.reward-content .content-group')
      groups = _doc_groups.map {|x|
        {
          title: x.css('h2').text.strip,
          html: x.inner_html.strip
        }
      }
      content = {
        titles: groups.map {|x| x[:title]},
        groups: groups
      }

      data = {
        brief: brief,
        content: content
      }
    end

    def parse_save
      if self.is_404
        puts "ignore: #{@id}"
        return
      end

      data = self.parse

      mpc = MartPageClean1.where(page_id: @id).first_or_create
      mpc.data = data
      mpc.save
      puts "clean1 done: #{@id}"
    rescue
      puts "第一轮数据清洗失败：#{@id}"
    end

    def self.parse_all
      MartPage.all.each do |mp|
        m = MartPageParser1.new mp.page_id
        m.parse_save
      end
    end
  end
end