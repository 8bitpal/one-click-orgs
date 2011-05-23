require 'spec_helper'

describe "founding members" do
  
  before(:each) do
    stub_organisation!(false)
    @organisation.pending!
    set_permission!(default_user, :direct_edit, true)
    set_permission!(default_user, :membership_proposal, true)
    login
    @user.member_class = @organisation.member_classes.find_by_name("Founder")
    @user.save!
  end
  
  describe "POST /founding_member" do
    context "when valid member attributes are given" do
      before(:each) do
        post('/founding_members', :founding_member => {:first_name => "Bob", :last_name => "Smith", :email => "bob@example.com"})
      end
      
      it "creates a new member" do
        @organisation.members.last.email.should == "bob@example.com"
      end
      
      it "sets the correct member class" do
        @organisation.members.last.member_class.name.should == "Founding Member"
      end
      
      it "redirect to members/index" do
        response.should redirect_to('/members')
      end
    end
    
    context "when invalid member attributes are given" do
      before(:each) do
        # Missing email
        post('/founding_members', :founding_member => {:first_name => "Bob", :last_name => "Smith", :email => ""})
      end
      
      it "sets a helpful error flash" do
        flash[:error].should =~ /Email/
      end
      
      it "renders the new member page" do
        response.should render_template('founding_members/new')
      end
      
      it "retains the contents of the new member form" do
        response.should have_selector('input', :name => 'founding_member[first_name]', :value => 'Bob')
      end
    end
  end
  
end
