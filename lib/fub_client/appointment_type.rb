module FubClient
  class AppointmentType < Resource
    collection_path 'appointmentTypes'
    root_element :appointment_type
    include_root_in_json true

    # Convenience method to find appointment types by name (partial match)
    scope :by_name, ->(name) { where(q: name) }

    # Convenience method to find active appointment types
    def self.active
      where(active: true)
    end

    # Convenience method to find inactive appointment types
    def self.inactive
      where(active: false)
    end

    # Get appointments with this type
    def appointments
      return [] unless id

      FubClient::Appointment.by_type(id)
    end

    # Update an appointment type
    def update(attributes)
      return false unless id

      begin
        self.class.put(id.to_s, attributes)
        true
      rescue StandardError
        false
      end
    end

    # Delete an appointment type
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
