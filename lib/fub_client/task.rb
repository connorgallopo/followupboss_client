module FubClient
  class Task < Resource
    collection_path "tasks"
    root_element :task
    include_root_in_json true
    
    scope :by_person, -> (person_id) { where(personId: person_id) }
    scope :by_type, -> (type) { where(type: type) }
    scope :by_status, -> (status) { where(status: status) }
    scope :due_before, -> (date) { where(dueBefore: date) }
    scope :due_after, -> (date) { where(dueAfter: date) }
    scope :assigned_to, -> (user_id) { where(assignedTo: user_id) }
    
    def self.overdue
      where(status: 'pending').where(dueBefore: Time.now.iso8601)
    end
  end
end
