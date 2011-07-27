class Company < Organisation
  has_many :meetings, :foreign_key => 'organisation_id'
  
  def create_default_member_classes
    member_classes.find_or_create_by_name('Director')
  end
  
  def set_default_voting_systems
    constitution.set_voting_system(:general, 'RelativeMajority')
  end
end
