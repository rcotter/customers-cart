# Global config with benefits:
# - Enables object like access E.g. AppConfig.simulate? instead of APP_CONFIG['simulate?']
# - Trying AppConfig.missing_property where 'missing_property' does not exist raises an error.
#
# Examples:
#
#   AppConfig.key instead of CONFIG['key']
#   AppConfig.nested.key instead of CONFIG['nested']['key']
#
class StrongConfig < OpenStruct

  # Build the strong configuration object from a raw hash that can have nested hierarchy
  #
  # @param [Hash] config
  def self.build(config)
    JSON.parse(config.to_json, object_class: StrongConfig)
  end

  # Raises an error if the member is missing
  def method_missing(member, *args)
    raise "#{self.class.name} missing member '#{member}'" unless member.to_s.end_with?('=')
    super
  end
end
