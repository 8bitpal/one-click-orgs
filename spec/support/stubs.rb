def default_user
  stub_constitution!
  stub_organisation!
    
  Member.first(:email => "krusty@clown.com") || 
    Member.create(:email => "krusty@clown.com",
                 :name => "Krusty the clown",
                 :password => "password",
                 :password_confirmation => "password") or raise "can't create user"
end

def stub_constitution!
  Constitution.stub!(:voting_period).and_return(3 * 86400)
  # Constitution.stub!(:voting_system).and_return(VotingSystems.get(:RelativeMajority))
end

def stub_organisation!
  organisation_is_active
  Organisation.stub!(:domain).and_return('http://test.com')
  Organisation.stub!(:name).and_return('test')
end

def login
  @user = default_user
  request("/login", {
    :method => "PUT",
    :params => {
      :email => @user.email,
      :password => "password"
    }
  }).should redirect_to('/')
  @user
end


def passed_proposal(p, args={})
  p.stub!(:passed?).and_return(true)
  lambda { p.enact!(args) }
end

def organisation_is_pending
  # FIXME should be Organistaion.stub!(:state)
  
  Organisation.stub!(:pending?).and_return(true)      
  Organisation.stub!(:active?).and_return(false)      
  Organisation.stub!(:under_construction?).and_return(false)
end

def organisation_is_active
  # FIXME should be Organistaion.stub!(:state)
  
  Organisation.stub!(:pending?).and_return(false)      
  Organisation.stub!(:active?).and_return(true)      
  Organisation.stub!(:under_construction?).and_return(false)
end

def organisation_is_under_construction
  # FIXME should be Organistaion.stub!(:state)
  
  Organisation.stub!(:pending?).and_return(false)      
  Organisation.stub!(:active?).and_return(false)      
  Organisation.stub!(:under_construction?).and_return(true)
end  

