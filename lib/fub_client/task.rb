module FubClient
  class Task < Resource
    collection_path "tasks"
    root_element :task
    include_root_in_json true
    
    # Convenience method to find tasks by person
    scope :by_person, -> (person_id) { where(personId: person_id) }
    
    # Convenience method to find tasks by task type
    scope :by_type, -> (type) { where(type: type) }

    # Convenience method to find tasks by status (completed, pending, etc.)
    scope :by_status, -> (status) { where(status: status) }
    
    # Convenience method to find tasks by due date
    scope :due_before, -> (date) { where(dueBefore: date) }
    scope :due_after, -> (date) { where(dueAfter: date) }
    
    # Convenience method to find overdue tasks
    def self.overdue
      where(status: 'pending').where(dueBefore: Time.now.iso8601)
    end
    
    # Find tasks assigned to a specific user
    scope :assigned_to, -> (user_id) { where(assignedTo: user_id) }
  end
end
