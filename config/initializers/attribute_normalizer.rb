#
# Model attribute normalizer
# https://github.com/mdeering/attribute_normalizer
#

AttributeNormalizer.configure do |config|
  ActiveRecord::Base.send :include, AttributeNormalizer

  config.normalizers[:downcase] = lambda do |text, options|
    text.try(:downcase) || text
  end

  config.normalizers[:float] = lambda do |text, options|
    text&.to_s&.gsub(/[^\-0-9.]/, '')&.to_f || text
  end

  config.default_normalizers = :strip, :blank
end