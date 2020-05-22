require 'csv'
require 'json'

class Charactor < ActiveRecord::Base
  validates :name, uniqueness: { scope: :session_id }
  ACCEPTED_NPC_ATTRIBUTES = %w[
    name
    siz
    app
    str
    con
    dex
    int
    edu
    pow
    san
  ]
  attr_accessor :parsed_params

  def self.load_from_csv!(session_id)
    file_name =  "tmp/raw_data.csv"
    csv = CSV.open(file_name)
    headers = csv.readline

    csv.each do |row|
      Charactor.create!(
        session_id: session_id,
        player_name: row[headers.find_index("シート名")],
        name: row[headers.find_index("キャラ名")],
        siz: row[headers.find_index("SIZ(体格)")],
        app: row[headers.find_index("APP(外見)")],
        str: row[headers.find_index("STR(筋力)")],
        con: row[headers.find_index("CON(体力)")],
        dex: row[headers.find_index("DEX(敏捷)")],
        int: row[headers.find_index("INT(知性)")],
        edu: row[headers.find_index("EDU(教育)")],
        pow: row[headers.find_index("POW(精神力)")],
        san: row[headers.find_index("現在の正気")],
        raw_data: [headers, row].transpose.to_h.to_json
      )
    end
  end

  def self.create_npc!(session_id, name, params)
    i = self.new(session_id: session_id, name: name, npc: true)
    if params.present?
      i.parse_params(params)
      i.validate_params
      i.assign_with_valid_params
    end
    i.save!
    i
  end

  def parse_params(params)
    @parsed_params ||= params.split(",").map do |param|
      key, val = param.split(":")
    end
  end

  # valid =>   "dex:10,str:10"
  # invalid => "dex:",
  # inbalid => "dex:10,str:"
  def validate_params
    parsed_params.each do |key, val|
      unless ACCEPTED_NPC_ATTRIBUTES.include? key
        raise "Do not attribute: #{key}"
      end
      if val.blank?
        raise "Do not blank value."
      end
    end
  end

  def assign_with_valid_params
    parsed_params.each do |key, val|
      self.send("#{key}=", val)
    end
  end
end
