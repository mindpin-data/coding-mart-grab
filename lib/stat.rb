module CodingMart
  class Stat
    include Mongoid::Document
    include Mongoid::Timestamps

    field :title
    field :data

    def self.save_data(title, data)
      s = Stat.where(title: title).first_or_create
      s.data = data
      s.save
    end

    def self.save_statuses
      statuses = CodingMart::MartPageClean1.all.map {|x| x.data[:brief][:status]}.uniq
      statuses = statuses.map {|s|
        count = CodingMart::MartPageClean1.where(:'data.brief.status' => s).count
        {status: s, count: count}
      }

      id_max = CodingMart::MartPageClean1.order(page_id: :desc).first().page_id
      db_count = CodingMart::MartPageClean1.count

      data = {
        id_max: id_max,
        invalid_count: id_max - db_count,
        db_total: db_count,
        sum_total: statuses.sum{|x| x[:count]},
        statuses: statuses
      }

      save_data '项目状态统计', data
    end

    def self.save_types
      types = CodingMart::MartPageClean1.all.map {|x| x.data[:brief][:detail][:type]}.uniq
      statuses = CodingMart::MartPageClean1.all.map {|x| x.data[:brief][:status]}.uniq

      groups = statuses.map {|s|
        _pages = CodingMart::MartPageClean1.where(:'data.brief.status' => s)
        _types = types.map {|x|
          count = _pages.where(:'data.brief.detail.type' => x).count
          {type: x, count: count}
        }

        desc = _types.sort {|a, b| 
          b[:count] <=> a[:count]
        }.map {|x|
          "#{x[:type]}(#{x[:count]})"
        }.join(" > ")

        total = _types.sum {|x| x[:count]}

        {status: s, total: total, desc: desc, types: _types}
      }

      data = {
        groups: groups,
      }

      save_data '项目类型统计', data
    end
  end
end