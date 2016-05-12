def fedex_credentials
  @fedex_credentials ||= test_credentials["development"]
end

def fedex_production_credentials
  @fedex_production_credentials ||= test_credentials["production"]
end

private

def test_credentials
  @credentials ||= begin
    YAML.load_file("#{File.dirname(__FILE__)}/../config/fedex_credentials.yml")
  end
end
