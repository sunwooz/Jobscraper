module JobsHelper

  def search_field_blank?
    params[:search].blank?
  end
end
