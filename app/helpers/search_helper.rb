module SearchHelper

  def search_result_field(value, search_facet = nil)
    Rails.logger.debug("search_result_field: \n\tvalue:#{value}\n\tsearch_facet:#{search_facet}\n\tparams[:#{search_facet}]:#{params[search_facet]}")
    # given a value and an optional search facet, highlight the value in the string
    terms = [params[:q].to_s, params[search_facet].to_s].compact.delete_if(&:blank?)
    Rails.logger.debug("\tterms: #{terms}")
    terms.any? ? highlight(value.to_s, terms) : value
  end

  # frozen_string_literal: true
  def action
    if action_name == 'advanced_search'
      :post
    else
      :get
    end
  end

  def link_to_toggle_search_modes
    if action_name == 'advanced_search'
      link_to('Go to Simple mode', 'search/indexRansack')
    else
      link_to('Go to Advanced mode', 'search/indexRansack')
    end
  end

  def person_column_headers
    %i(id first_name last_name email_address created_at updated_at).freeze
  end

  def person_column_fields
    %i(id first_name last_name email_address created updated).freeze
  end

  def results_limit
    # max number of search results to display
    10
  end

  def condition_fields
    %w(fields condition).freeze
  end

  def value_fields
    %w(fields value).freeze
  end

  def display_distinct_label_and_check_box
    tag.section do
      check_box_tag(:distinct, '1', user_wants_distinct_results?, class: :cbx) +
        label_tag(:distinct, 'Return distinct records')
    end
  end

  def user_wants_distinct_results?
    params[:distinct].to_i == 1
  end

  def display_query_sql(people)
    tag.p('SQL:') + tag.code(people.to_sql)
  end

end
