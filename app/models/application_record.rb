# typed: true
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.attributes
    self.column_names.map(&:to_sym)
  end
end
