class SigsController < ResourceController
  def resource_class
    Sig
  end
  
  def validate_delete(resource)
    resource.events.empty? ? nil : 'Cannot delete SIG if it has events.'
  end
end