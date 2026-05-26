module JobHelper
  def highlight_search_terms(text, query)
    return text if query.blank?

    escaped_query = Regexp.escape(query)

    highlighted_text = text.gsub(/(#{escaped_query})/i, '<mark>\1</mark>')

    highlighted_text.html_safe
  end
end
