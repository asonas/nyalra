class Parser
  attr_accessor :url

  def self.run(csv)
    new(url).run
  end

  def initialize(url)
    @url = url
  end

  def run
    puts "hi #{@url}"
    response = Spreadsheet2Csv.run(@url)
  end
end
Parser.run("aaa")
