module FubClient
  class AppointmentOutcome < Resource
    collection_path 'appointmentOutcomes'
    root_element :appointment_outcome
    include_root_in_json true

    # Convenience method to find appointment outcomes by name (partial match)
    scope :by_name, ->(name) { where(q: name) }

    # Convenience method to find active appointment outcomes
    def self.active
      where(active: true)
    end

    # Convenience method to find inactive appointment outcomes
    def self.inactive
      where(active: false)
    end

    # Get appointments with this outcome
    def appointments
      return [] unless id

      FubClient::Appointment.by_outcome(id)
    end

    # Update an appointment outcome
    def update(attributes)
      return false unless id

      begin
        self.class.put(id.to_s, attributes)
        true
      rescue StandardError
        false
      end
    end

    # Delete an appointment outcome
    def delete
      return false unless id

      begin
        self.class.delete(id.to_s)
        true
      rescue StandardError
        false
      end
    end
  end
end
