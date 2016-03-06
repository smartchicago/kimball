module SearchHelper

  def search_result_field(value, search_facet = nil)
    Rails.logger.debug("search_result_field: \n\tvalue:#{value}\n\tsearch_facet:#{search_facet}\n\tparams[:#{search_facet}]:#{params[search_facet]}")
    # given a value and an optional search facet, highlight the value in the string
    terms = [params[:q].to_s, params[search_facet].to_s].compact.delete_if(&:blank?)
    Rails.logger.debug("\tterms: #{terms}")
    terms.any? ? highlight(value.to_s, terms) : value
  end

end
