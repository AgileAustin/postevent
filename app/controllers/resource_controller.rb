class ResourceController < ApplicationController
  before_filter :login_required

  def index
    @resources = resource_class.all(:order => order_by)
   
    respond_to do |format|
      format.html  # index.html.erb
      format.json  { render :json => @resources }
    end
  end

  def show
    @resource = resource_class.find(params[:id])
   
    respond_to do |format|
      format.html  # show.html.erb
      format.json  { render :json => @resource }
    end
  end

  def new
    @resource = new_resource
 
    respond_to do |format|
      format.html  # new.html.erb
      format.json  { render :json => @resource }
    end
  end

  def create
    @resource = resource_class.new(params[resource_parameter])
    @result = false
   
    respond_to do |format|
      if @resource.save
        flash[:error] = created_message
        format.html  { redirect_to(:action => "new") }
        format.json  { render :json => @resource,
                      :status => :created, :location => @resource }
        @result = true
      else
        format.html  { render :action => "new" }
        format.json  { render :json => @resource.errors,
                      :status => :unprocessable_entity }
      end
    end
    @result
  end

  def edit
    @resource = resource_class.find(params[:id])
  end

  def update
    @resource = resource_class.find(params[:id])
    @result = false
   
    respond_to do |format|
      if @resource.update_attributes(params[resource_parameter])
        flash[:notice] = updated_message
        format.html  { redirect_to(:action => "index") }
        format.json  { head :no_content }
        @result = true
      else
        format.html  { render :action => "edit" }
        format.json  { render :json => @resource.errors,
                      :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @resource = resource_class.find(params[:id])
    @error = validate_delete(@resource)
    respond_to do |format|
      if @error
        flash[:notice] = @error
        format.html  { redirect_to :action => "index" }
        format.json  { render :json => @errors,
                      :status => :unprocessable_entity }
      else
        @resource.destroy
       
        format.html { redirect_to :action => "index" }
        format.json { head :no_content }
      end
    end
  end

private

  def order_by
    'name'
  end
  
  def new_resource
    resource_class.new
  end

  def validate_delete(resource)
    nil
  end
  
  def resource_name
    resource_class.name
  end
  
  def resource_parameter
    resource_class.name.downcase.to_sym
  end
  
  def resource_class
    raise "Resource class not defined"
  end
  
  def created_message
    resource_name + ' was successfully created.'
  end
  
  def updated_message
    resource_name + ' was successfully updated.'
  end
end