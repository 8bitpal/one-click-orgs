require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Decision do

  it "should selected closed early decsions" do
    member_0 = Member.create(:name => 'm0', :email => 'm0@blah.com', :created_at => Time.now - 1.day)  
    member_1 = Member.create(:name => 'm1', :email => 'm1@blah.com', :created_at => Time.now - 1.day)
    member_2 = Member.create(:name => 'm2', :email => 'm2@blah.com', :created_at => Time.now - 1.day)  
    
    proposal = Decision.create(:proposer_member_id => member_1.id, :title => 'test')
    
    member_3= Member.create(:name => 'm3', :email => 'm3@blah.com', :created_at => Time.now + 1.day)
    member_4= Member.create(:name => 'm4', :email => 'm4@blah.com', :created_at => Time.now + 1.day)
    
    member_0.cast_vote(:for, proposal.id)
    member_1.cast_vote(:for, proposal.id)
    member_2.cast_vote(:for, proposal.id)    
    
    Decision.find_closed_early_decisions.should include(proposal)
  end

end