module Core
  # Introduces Aggregated and Tracked behavior to ActiveRecord::Base models, as well
  # as Macros and Extensions modules for more efficient usage. Effectively replaces
  # both Aggregatable and Trackable modules.
  module Behaviors
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    autoload :AggregatedBehavior
    autoload :TrackedBehavior
    autoload :Macros
    autoload :Extensions

    included do
      include Extensions
      extend Macros
    end

    # :nodoc:
    module ClassMethods
      # Adds aggregated behavior to a model.
      def acts_as_aggregated
        include AggregatedBehavior
      end
      private :acts_as_aggregated

      # Adds tracked behavior to a model
      def acts_as_tracked
        include TrackedBehavior
      end
      private :acts_as_tracked
    end

    # Marks +self+ as a new record. Sets +id+ attribute to nil, but memorizes
    # the old value in case of exception.
   def to_new_record!
      @_id_before_to_new_record = id
      self.id = nil
      self.updated_at = nil
      self.created_at = nil
      @new_record = true
    end

    # Marks +self+ as persistent record. If another record is passed, uses its
    # persistence attributes (id, timestamps). If nil is passed as an argument,
    # marks +self+ as persisted record and sets +id+ to memorized value.
    def to_persistent!(existing = nil)
      if existing
        self.id         = existing.id
        self.created_at = existing.created_at if respond_to?(:created_at)
        self.updated_at = existing.updated_at if respond_to?(:updated_at)
        @changed_attributes = {}
      else
        self.id = @_id_before_to_new_record
      end
      @new_record = false
      true
    end

    # Helper method used by has_aggregated (in fact, belongs_to)
    # association during autosave.
    def updated_as_aggregated?
      !!@updated_as_aggregated
    end

    # Helper method indicating the record is not tracked. Overridden by
    # TrackedBehavior module.
    def tracked?
      false
    end
  end
end
