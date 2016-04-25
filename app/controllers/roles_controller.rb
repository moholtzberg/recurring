class RolesController < ApplicationController
  layout "admin"

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
  end

  def edit
    @role = Role.find_by(id: params[:id])
  end

  def create
    @role = Role.new(:name => params[:role][:name].downcase)
    begin
      @role.save
    rescue
    end
    @roles = Role.all
  end

  def update
    @role = Role.find_by(id: params[:id])
    begin
      @role.update_attributes(:name => params[:role][:name].downcase)
    else
    end
    @roles = Role.all    
    respond_to do |format|
      format.js { render "/roles/create" }
    end
  end

  def show
    @role = Role.find(params[:id])
  end

  def destroy
    @role = Role.find(params[:id])
    User.all.each do |user|
      if user.has_role(@role.name)
        user.remove_role @role.name
      end
    end
    @role.destroy!
    @roles = Role.all    
    respond_to do |format|
      format.js { render "/roles/create" }
    end
  end  

end