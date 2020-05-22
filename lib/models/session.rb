class Session < ActiveRecord::Base
  has_many :charactors

  def all_charactors
    cs = []
    self.charactors.each.with_index(1) do |c, i|
      cs.push "#{i} #{c.name}"
    end
    cs
  end
end
