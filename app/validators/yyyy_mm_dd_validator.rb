# Validate YYYY-MM-DD dates in a way that ACTUALLY reports format problems instead
# of forcing a cast to the field type and swallowing errors. Instead,
#
# Use:
#
#    validate :validate_date_field
#
#    def validate_date_field
#      YyyyMmDdValidator.validate(self, :date_field) # or
#      YyyyMmDdValidator.validate(self, :date_field, {allow_nil: true})
#    end
#
class YyyyMmDdValidator

  def self.validate(record, attribute, options=nil, error_message=nil)
    value = record.try(:attributes_before_type_cast).try(:[], attribute.to_s)
    unless value.nil? && (options || {})[:allow_nil]
      YyyyMmDdValidator.perform(record, attribute, value, error_message)
    end
  end

  private

  def self.perform(record, attribute, value, error_message)
    unless value.to_s =~ /^(19|20)\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$/
      record.errors[attribute] << (error_message || 'YYYY-MM-DD date expected')
    end
  end
end