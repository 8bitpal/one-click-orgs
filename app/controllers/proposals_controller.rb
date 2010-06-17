class ProposalsController < ApplicationController

  respond_to :html
  
  before_filter :require_freeform_proposal_permission, :only => [:create]
  
  before_filter :require_constitutional_proposal_permission, :only => [
    :create_text_amendment, :create_assets_amendment, :create_voting_period_amendment,
    :create_voting_system_amendment]
  
  def index
    # Fetch open proposals
    @proposals = Proposal.currently_open
    
    # Fetch five most recent decisions
    @decisions = Decision.order("id DESC").limit(5)
    
    # Fetch five most recent failed proposals
    @failed_proposals = Proposal.failed.limit(5)
  end

  def show
    @proposal = Proposal.find(params[:id])
    respond_with @proposal
  end

  def create
    @proposal = Proposal.new(params[:proposal])
    @proposal.proposer_member_id = current_user.id #fixme
        
    if @proposal.save
      redirect_to proposal_path(@proposal), :flash => {:notice => "Proposal was successfully created"}
    else
      redirect root_path, :flash => {:error => "Proposal not created"}
    end
  end
  
  def create_text_amendment
    proposal = ChangeTextProposal.new(
      :title => "Change #{params[:name].humanize.downcase} to '#{params[:value]}'",
      :proposer_member_id => current_user.id,
      :parameters => ChangeTextProposal.serialize_parameters(
        'name' => params[:name],
        'value' => params[:value]
      )
    )
    if proposal.save
      redirect_to({:controller => 'one_click', :action => 'control_centre'}, :notice => "Constitutional amendment proposal succesfully created")
    else
      redirect_to(constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"})
    end
  end
  
  def create_assets_amendment
    if params[:new_assets_value] == '1'
      title = "Change the constitution to allow holding, transferral and disposal of material assets and intangible assets"
      new_assets_value = true
    else
      title = "Change the constitution to prohibit holding, transferral or disposal of material assets and intangible assets"
      new_assets_value = false
    end
    
    proposal = ChangeBooleanProposal.new(
      :title => title,
      :proposer_member_id => current_user.id,
      :parameters => ChangeBooleanProposal.serialize_parameters(
        'name' => 'assets',
        'value' => new_assets_value
      )
    )
    
    if proposal.save
      redirect_to({:controller => 'one_click', :action => 'control_centre'}, :notice => "Constitutional amendment proposal succesfully created")
    else
      redirect_to(constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"})
    end
  end
  
  def create_voting_period_amendment
    if params[:new_voting_period]
      proposal = ChangeVotingPeriodProposal.new(
        :title=>"Change voting period to #{VotingPeriods.name_for_value(params[:new_voting_period])}",
        :proposer_member_id => current_user.id,
        :parameters => ChangeVotingSystemProposal.serialize_parameters(
          'new_voting_period'=>params[:new_voting_period])
      )      
      if proposal.save
        redirect_to({:controller => 'one_click', :action => 'control_centre'}, :notice => "Constitutional amendment proposal succesfully created")
      else
        redirect_to(constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"})
      end
    end
  end
  
  def create_voting_system_amendment
    if params[:general_voting_system]
      proposed_system = VotingSystems.get(params[:general_voting_system])      
      current_system = Constitution.voting_system :general
      
      if current_system != proposed_system           
              
        proposal = ChangeVotingSystemProposal.new(
          :title => "change general voting system to #{proposed_system.description}",
          :proposer_member_id => current_user.id,
          :parameters => ChangeVotingSystemProposal.serialize_parameters('type'=>'general', 'proposed_system'=> proposed_system.simple_name)
        )

        if proposal.save
          redirect_to({:controller=>'one_click', :action=>'control_centre'}, :flash => {:notice=> "Change general voting system proposal successfully created"})
        else
          redirect_to constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"}      
        end

        return
      end
    elsif params[:membership_voting_system]
      proposed_system = VotingSystems.get(params[:membership_voting_system])
      current_system = Constitution.voting_system :membership
      
      if current_system != proposed_system
        proposal = ChangeVotingSystemProposal.new(
          :title => "change membership voting system to #{proposed_system.description}",
          :proposer_member_id => current_user.id,
          :parameters => ChangeVotingSystemProposal.serialize_parameters('type' => 'membership', 'proposed_system' => proposed_system.simple_name)
        )
        
        if proposal.save
          redirect_to({:controller=>'one_click', :action=>'control_centre'}, :flash => {:notice=> "Change membership voting system proposal successfully created"})
        else
          redirect_to constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"}
        end
        
        return
      end
    elsif params[:constitution_voting_system]
      proposed_system = VotingSystems.get(params[:constitution_voting_system])
      current_system = Constitution.voting_system :constitution
      
      if current_system != proposed_system
        proposal = ChangeVotingSystemProposal.new(
          :title => "change constitution voting system to #{proposed_system.description}",
          :proposer_member_id => current_user.id,
          :parameters => ChangeVotingSystemProposal.serialize_parameters('type' => 'constitution', 'proposed_system' => proposed_system.simple_name)
        )
        
        if proposal.save
          redirect_to({:controller=>'one_click', :action=>'control_centre'}, :flash => {:notice=> "Change constitution voting system proposal successfully created"})
        else
          redirect_to constitution_path, :flash => {:error => "Error creating proposal: #{proposal.errors.inspect}"}
        end
        
        return
      end
      
    
    end
    
    redirect_to constitution_path, :flash => {:error => "No changes."}                
  end

private

  def require_freeform_proposal_permission
    if !current_user.has_permission(:freeform_proposal)
      flash[:error] = "You do not have sufficient permissions to create such a proposal!"
      redirect_back_or_default
    end
  end
  
  def require_constitutional_proposal_permission
    if !current_user.has_permission(:constitution_proposal)
      flash[:error] = "You do not have sufficient permissions to create such a proposal!"
      redirect_back_or_default
    end
  end

end # Proposals
