require "googleauth"
require "google/apis/sheets_v4"
require "googleauth/stores/file_token_store"
require "fileutils"
require 'csv'

require 'pry'

class SpreadsheetClient
  # ref: https://developers.google.com/sheets/api/quickstart/ruby
  OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
  APPLICATION_NAME = "Google Sheets API Ruby Quickstart".freeze
  CREDENTIALS_PATH = "credentials.json".freeze
  TOKEN_PATH = "token.yaml".freeze
  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

  SPREADSHEET_ID = "15kAbGZYsSN3rlMt-RNi4Xg91AsFtYR9tFILYOXVc3a4"

  attr_accessor :url

  def initialize(url)
    @url = URI.parse(url)

    # Initialize the API
    @service = Google::Apis::SheetsV4::SheetsService.new
    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = authorize
  end

  def get_spreadsheet
    @service.get_spreadsheet spreadsheet_id
  end

  def spreadsheet_id
    @url.path.split("/")[3]
  end

  def save_charactor_to_csv
    range = "csv!A1:CR"
    response = @service.get_spreadsheet_values spreadsheet_id, range

    # Spreadsheet to CSV
    CSV.open("tmp/raw_data.csv", "wb") do |csv|
      response.values.each do |row|
        csv << row
      end
    end
  end

  def authorize
    client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
    token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
    authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
    user_id = "default"
    credentials = authorizer.get_credentials user_id
    if credentials.nil?
      url = authorizer.get_authorization_url base_url: OOB_URI
      puts "Open the following URL in the browser and enter the " \
           "resulting code after authorization:\n" + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end
end

