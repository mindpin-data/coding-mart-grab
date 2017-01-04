module CodingMart
  # 原始抓取数据
  class MartPage
    include Mongoid::Document
    include Mongoid::Timestamps

    field :page_id
    field :page_html
  end

  # 第一次数据清洗
  class MartPageClean1
    include Mongoid::Document
    include Mongoid::Timestamps

    field :page_id
    field :data
  end
end