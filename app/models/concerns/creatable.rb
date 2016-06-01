# Re-usable tracking of whether this record was just saved for the first time.
module Creatable
  extend ActiveSupport::Concern

  def self.included(base)
    base.class_eval do
      after_create :set_created
    end
  end

  def created?
    !!@created
  end

  private

  def set_created
    @created = true
  end
end