class ApplicationController < ActionController::API
  include ParamsHelper
  include RenderHelper
  include SaveHelper
  include Errors

  before_action :convert_boolean_params
  before_action :cors_header

  def options
    head status: :ok
  end

  protected

  def legacy_db
    opts = {
      host: ENV['LEGACY_CS198_DB_HOST'],
      username: ENV['LEGACY_CS198_DB_USER'],
      password: ENV['LEGACY_CS198_DB_PASS'],
      port: ENV['LEGACY_CS198_DB_PORT'],
      database: ENV['LEGACY_CS198_DB_DB']
    }.delete_if { |_, v| v.nil? }

    Mysql2::Client.new opts
  end

  WHITELISTED_DOMAINS = [
    "lair-queue-prod-f9m6cpgaut.elasticbeanstalk.com",
    "cs198.stanford.edu",
    "localhost:8080"
  ]

  # To allow requests from whitelisted domains to bypass the Same-Origin Policy
  def cors_header
    origin = request.headers['Origin']
    if ENV['RAILS_ENV'] == 'production'
      headers["Access-Control-Allow-Origin"] = origin if check_origin origin
    else
      headers["Access-Control-Allow-Origin"] = origin unless origin.nil? # always pass if testing
    end
    headers["Access-Control-Allow-Methods"] = "GET,PUT,POST,DELETE"
  end

  private

  def check_origin(origin)
    !WHITELISTED_DOMAINS.map { |d| Regexp.new("https?://#{d}").match origin }.reject(&:nil?).empty?
  end

  def convert_boolean_params
    self.params = coerce_boolean_strings params unless params.nil?
  end
end
